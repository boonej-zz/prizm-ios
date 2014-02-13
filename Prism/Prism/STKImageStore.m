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
    }
    return self;
}

- (NSString *)cachePath
{
    if(!_cachePath) {
        _cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"imagecache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _cachePath;
}

- (BOOL)fetchImageForURLString:(NSString *)urlString completion:(void (^)(UIImage *img))block
{
    NSString *cachePath = [self cachePathForURLString:urlString];
    
    UIImage *img = [[self memoryCache] objectForKey:cachePath];
    if(img) {
        block(img);
        return YES;
    }
    
    
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:cachePath];
    if(fileData) {
        img = [UIImage imageWithData:fileData];
        [[self memoryCache] setObject:img forKey:cachePath];
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

- (UIImage *)uploadImage:(UIImage *)image size:(CGSize)sz intoDirectory:(NSString *)directory completion:(void (^)(NSString *URLString, NSError *err))block
{
    UIGraphicsBeginImageContextWithOptions(sz, YES, 1.0);
    [image drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self uploadImage:resizedImage intoDirectory:directory completion:block];

    return resizedImage;
}

- (void)uploadImage:(UIImage *)image intoDirectory:(NSString *)directory completion:(void (^)(NSString *URLString, NSError *err))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        const void *cStr = [imageData bytes];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        
        CC_MD5(cStr, (uint32_t)[imageData length], result);
        
        NSUUID *uuid = [[NSUUID alloc] init];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMddhhmmss"];
        
        NSString *fileName = [NSString stringWithFormat:@"%@/%@_%@.jpg", directory, [df stringFromDate:[NSDate date]], [uuid UUIDString]];
        fileName = [fileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        
        S3PutObjectRequest *req = [[S3PutObjectRequest alloc] initWithKey:fileName inBucket:STKImageStoreBucketName];
        
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

@end
