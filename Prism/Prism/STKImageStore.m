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
        _failedFetchMap = [[NSMutableDictionary alloc] init];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        _fetchSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
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

- (BOOL)fetchImageForURLString:(NSString *)url completion:(void (^)(UIImage *img))block
{
    NSString *cachePath = [self cachePathForURLString:url];
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:cachePath];
    if(fileData) {
        block([UIImage imageWithData:fileData]);
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
    
    NSURLSessionDownloadTask *t = [[self fetchSession] downloadTaskWithURL:[NSURL URLWithString:url]
                                                         completionHandler:
                                   ^(NSURL *location, NSURLResponse *response, NSError *error) {
                                       if(!error) {
                                           NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                           if(statusCode / 100 == 2) {
                                               // This was a success.
                                               [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                       toURL:[NSURL fileURLWithPath:cachePath]
                                                                                       error:nil];
                                               NSData *data = [NSData dataWithContentsOfFile:cachePath];
                                               block([UIImage imageWithData:data]);
                                               return;
                                           } else {
                                               // We could reach the server and all, but the image wasn't there, so let's
                                               // not try fetching it for awhile.
                                               [[self failedFetchMap] setObject:[NSDate date]
                                                                         forKey:cachePath];
                                           }
                                       }                                       
                                       block(nil);
                                   }];
    [t resume];
    return NO;
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

- (void)uploadImage:(UIImage *)image completion:(void (^)(NSString *URLString, NSError *err))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        const void *cStr = [imageData bytes];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        
        CC_MD5(cStr, (uint32_t)[imageData length], result);
        
        NSString *md5 = [[[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH] base64EncodedStringWithOptions:0];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMddhhmmss"];
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg", [df stringFromDate:[NSDate date]], md5];
        
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
            block(nil, [response error]);
        }
    });
}

@end
