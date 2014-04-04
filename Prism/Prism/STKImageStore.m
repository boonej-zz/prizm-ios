//
//  STKImageStore.m
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKImageStore.h"
#import <CommonCrypto/CommonCrypto.h>
#import "AmazonS3Client.h"


NSString * const STKImageStoreS3Key = @"27F1TqpcdXOzi6DLmt9U4LCdlI71EhtwhClX0XMl";
NSString * const STKImageStoreS3KeyID = @"AKIAI7E5TSPROBCA4YWA";
NSString * const STKImageStoreBucketName = @"higheraltitude.prism";
NSString * const STKImageStoreBucketHostURLString = @"https://s3.amazonaws.com";

@interface STKImageStore () <NSURLSessionDelegate>

@property (nonatomic, strong) AmazonS3Client *amazonClient;
@property (nonatomic, strong) NSURLSession *fetchSession;
@property (nonatomic, readonly) NSString *cachePath;
@property (nonatomic, strong) NSMutableDictionary *failedFetchMap;
@property (nonatomic, strong) NSMapTable *memoryCache;

@property (nonatomic, strong) NSMutableArray *throttleQueue;
@property (nonatomic, strong) NSMutableArray *activeQueue;
@property (nonatomic, strong) NSMutableDictionary *callbackMap;

- (NSString *)safeStringForURLString:(NSString *)url;

- (NSString *)cachePathForURLString:(NSString *)url;

@end

@implementation STKImageStore
@synthesize cachePath = _cachePath;

+ (STKImageStore *)store
{
    static STKImageStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKImageStore alloc] init];
    });
    return store;
}

- (id)init
{
    self = [super init];
    if(self) {
        
        _callbackMap = [[NSMutableDictionary alloc] init];
        _activeQueue = [[NSMutableArray alloc] init];
        _throttleQueue = [[NSMutableArray alloc] init];
        _memoryCache = [NSMapTable strongToWeakObjectsMapTable];
        _failedFetchMap = [[NSMutableDictionary alloc] init];
        
        _fetchSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                                      delegate:self
                                                 delegateQueue:[NSOperationQueue mainQueue]];
    
        _amazonClient = [[AmazonS3Client alloc] initWithAccessKey:STKImageStoreS3KeyID
                                                    withSecretKey:STKImageStoreS3Key];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)clearCache:(id)sender
{
    [[self memoryCache] removeAllObjects];
}

- (NSString *)cachePath
{
    if(!_cachePath) {
        _cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"imagecache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _cachePath;
}

- (UIImage *)bestCachedImageForURLString:(NSString *)url
{
    NSArray *paths = @[
                [self thumbnailPathForURLString:url size:STKImageStoreThumbnailNone],
                [self thumbnailPathForURLString:url size:STKImageStoreThumbnailLarge],
                [self thumbnailPathForURLString:url size:STKImageStoreThumbnailMedium],
                [self thumbnailPathForURLString:url size:STKImageStoreThumbnailSmall]
    ];
    
    for(NSString *path in paths) {
        UIImage *img = [self cachedImageForURLString:path];
        if(img)
            return img;
    }
    return nil;
}

- (UIImage *)cachedImageForURLString:(NSString *)url
{
    NSString *cachePath = [self cachePathForURLString:url];
    
    UIImage *img = [[self memoryCache] objectForKey:cachePath];
    if(img) {
        return img;
    }
    
    
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:cachePath];
    if(fileData) {
        img = [UIImage imageWithData:fileData];
        [[self memoryCache] setObject:img forKey:cachePath];
        return img;
    }
    
    return nil;
}

- (NSString *)thumbnailPathForURLString:(NSString *)URLString size:(STKImageStoreThumbnail)size
{
    NSString *code = @"";
    switch(size) {
        case STKImageStoreThumbnailNone:
            return URLString;
        case STKImageStoreThumbnailLarge:
            code = @"2"; break;
        case STKImageStoreThumbnailMedium:
            code = @"4"; break;
        case STKImageStoreThumbnailSmall:
            code = @"8"; break;
        
    }
    
    NSString *stripExtension = [URLString stringByDeletingPathExtension];
    return [stripExtension stringByAppendingFormat:@"_%@.jpg", code];
}

- (void)fetchImageForURLString:(NSString *)url preferredSize:(STKImageStoreThumbnail)size completion:(void (^)(UIImage *img))block
{
    NSString *path = [self thumbnailPathForURLString:url size:size];
    
    [self fetchImageForURLString:path completion:^(UIImage *img) {
        if(img) {
            block(img);
        } else {
            NSLog(@"Failed to get %d at %@", size, url);
            if(size != STKImageStoreThumbnailNone) {
                [self fetchImageForURLString:url completion:block];
            }
        }
    }];
}

- (BOOL)fetchImageForURLString:(NSString *)urlString completion:(void (^)(UIImage *img))block
{
    NSString *cachePath = [self cachePathForURLString:urlString];
    
    UIImage *img = [self cachedImageForURLString:urlString];
    if(img) {
        block(img);
        return YES;
    }

    // If this image really didn't exist <2 minutes ago, then don't bother re-fetching it.
    // However, if we last tried over 2 minutes ago, go ahead and try again.
    NSDate *lastFailDate = [[self failedFetchMap] objectForKey:cachePath];
    if(lastFailDate) {
        NSTimeInterval i = [[NSDate date] timeIntervalSinceDate:lastFailDate];
        if(i < 120) {
            block(nil);
            return YES;
        }
        
        [[self failedFetchMap] removeObjectForKey:cachePath];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if(!url) {
        block(nil);
        return YES;
    }
    
    NSMutableArray *callbacks = [[self callbackMap] objectForKey:url];
    
    if(callbacks) {
        NSMutableArray * a = [[self callbackMap] objectForKey:url];
        [a addObject:block];

    } else {
        callbacks = [[NSMutableArray alloc] init];
        [callbacks addObject:block];
        [[self callbackMap] setObject:callbacks forKey:url];
        
        __block NSURLSessionDownloadTask *dtRef = nil;
        NSURLSessionDownloadTask *t = [[self fetchSession] downloadTaskWithURL:url
                                                             completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                 
                                                                 UIImage *image = nil;
                                                                 if(!error) {
                                                                     [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                             toURL:[NSURL fileURLWithPath:cachePath]
                                                                                                             error:nil];
                                                                     NSData *data = [NSData dataWithContentsOfFile:cachePath];
                                                                     
                                                                     image = [UIImage imageWithData:data];
                                                                     [[self memoryCache] setObject:image forKey:cachePath];
                                                                 } else {
                                                                     [[self failedFetchMap] setObject:[NSDate date] forKey:cachePath];
                                                                 }
                                                                 
                                                                 [[self activeQueue] removeObjectIdenticalTo:dtRef];
                                                                 
                                                                 for(void (^callbackBlock)(UIImage *img) in [[self callbackMap] objectForKey:url]) {
                                                                     callbackBlock(image);
                                                                 }
                                                                 [[self callbackMap] removeObjectForKey:url];
                                                                 
                                                                 [self dequeue];
                                                             }];
        
        dtRef = t;
        
        [[self throttleQueue] addObject:t];
        
        [self dequeue];
    }
    
    
    
    
    return NO;
}

- (void)dequeue
{
    if([[self activeQueue] count] < 3) {
        NSURLSessionDownloadTask *t = [[self throttleQueue] firstObject];
        if(t) {
            [[self activeQueue] addObject:t];
            [[self throttleQueue] removeObjectIdenticalTo:t];
            
            [t resume];
        }
    }
}

- (NSString *)cachePathForURLString:(NSString *)url
{
    return [[self cachePath] stringByAppendingPathComponent:[self safeStringForURLString:url]];
}

- (NSString *)safeStringForURLString:(NSString *)url
{
    // Remove protocol
    url = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];

    return [url stringByReplacingOccurrencesOfString:@"[^0-9A-Za-z_-]"
                                          withString:@""
                                             options:NSRegularExpressionSearch
                                               range:NSMakeRange(0, [url length])];
}

- (NSArray *)uploadPathsInDirectory:(NSString *)directory thumbnailCount:(int)count
{
    NSUUID *uuid = [[NSUUID alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddhhmmss"];
    
    NSString *base = [NSString stringWithFormat:@"%@/%@_%@", directory, [df stringFromDate:[NSDate date]], [uuid UUIDString]];

    NSMutableArray *paths = [[NSMutableArray alloc] init];
    [paths addObject:[base stringByAppendingPathExtension:@"jpg"]];
    for(int i = 0; i < count; i++) {
        int p = (int)pow(2, i + 1);
        [paths addObject:[[base stringByAppendingFormat:@"_%d", p] stringByAppendingPathExtension:@"jpg"]];
    }
    return [paths copy];
}

- (void)uploadImage:(UIImage *)image
     thumbnailCount:(int)thumbnailCount
      intoDirectory:(NSString *)directory
         completion:(void (^)(NSString *URLString, NSError *err))block
{
    NSArray *paths = [self uploadPathsInDirectory:directory thumbnailCount:thumbnailCount];
    
    NSMutableArray *thumbnails = [NSMutableArray array];
    UIImage *t = image;
    for(int i = 0; i < thumbnailCount; i++) {
        CGSize tSize = [t size];
        tSize.width = floor(tSize.width / 2.0);
        tSize.height = floor(tSize.height / 2.0);
        
        UIGraphicsBeginImageContextWithOptions(tSize, YES, 1);
        [t drawInRect:CGRectMake(0, 0, tSize.width, tSize.height)];
        t = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [thumbnails addObject:t];
    }

    if([thumbnails count] + 1 != [paths count]) {
        NSLog(@"Mismatch in thumbnails");
    }
    
    [self uploadImage:image toPath:[paths firstObject] completion:^(NSString *URLString, NSError *err) {
        block(URLString, err);
        
        if(!err) {
            NSMutableArray *tPaths = [NSMutableArray array];
            for(int i = 1; i < [paths count]; i++) {
                [tPaths addObject:[paths objectAtIndex:i]];
            }
            [self uploadThumbnailImages:thumbnails paths:tPaths];
        }
    }];
}

- (void)uploadThumbnailImages:(NSArray *)images paths:(NSArray *)paths
{
    if([paths count] == 0 || [images count] == 0)
        return;
    
    NSString *path = [paths objectAtIndex:0];
    UIImage *img = [images objectAtIndex:0];
    
    NSMutableArray *newPaths = [NSMutableArray array];
    NSMutableArray *newImages = [NSMutableArray array];
    for(int i = 1; i < [paths count]; i++) {
        [newPaths addObject:[paths objectAtIndex:i]];
    }
    for(int i = 1; i < [images count]; i++) {
        [newImages addObject:[images objectAtIndex:i]];
    }
    
    [self uploadImage:img toPath:path completion:^(NSString *URLString, NSError *err) {
        [self uploadThumbnailImages:newImages paths:newPaths];
    }];
}

- (void)uploadImage:(UIImage *)img toPath:(NSString *)fileName completion:(void (^)(NSString *URLString, NSError *err))block
{
    NSLog(@"Uploading image of size %@ to path %@", NSStringFromCGSize([img size]), fileName);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        S3PutObjectRequest *req = [[S3PutObjectRequest alloc] initWithKey:fileName inBucket:STKImageStoreBucketName];
        NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
        
        [req setContentType:@"image/jpeg"];
        [req setData:imageData];
        [req setCannedACL:[S3CannedACL publicRead]];
        
        S3PutObjectResponse *response = [[self amazonClient] putObject:req];
        if(![response error] && ![response exception]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *fullPath = [[STKImageStoreBucketHostURLString stringByAppendingPathComponent:STKImageStoreBucketName] stringByAppendingPathComponent:fileName];
                NSString *cachePath = [self cachePathForURLString:fullPath];
                [imageData writeToFile:cachePath atomically:YES];
                
                block(fullPath, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil, [response error]);
            });
        }
    });
}

- (void)uploadImage:(UIImage *)image intoDirectory:(NSString *)directory completion:(void (^)(NSString *URLString, NSError *err))block
{
    NSString *fileName = [[self uploadPathsInDirectory:directory thumbnailCount:0] firstObject];
    [self uploadImage:image toPath:fileName completion:block];
}

@end
