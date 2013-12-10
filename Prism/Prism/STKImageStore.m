//
//  STKImageStore.m
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKImageStore.h"

@interface STKImageStore () <NSURLSessionDelegate>

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
    return [url stringByReplacingOccurrencesOfString:@"[^0-9A-Za-z_-]"
                                          withString:@""
                                             options:NSRegularExpressionSearch
                                               range:NSMakeRange(0, [url length])];
}

@end
