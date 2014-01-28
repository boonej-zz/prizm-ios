//
//  STKContentStore.h
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPost.h"
@import CoreLocation;

@class STKUser;

extern NSString * const STKContentStoreErrorDomain;
typedef enum {
    STKContentStoreErrorCodeMissingArguments, // @[arg0, ...]
} STKContentStoreErrorCode;

typedef enum {
    STKContentStoreFetchDirectionNewer,
    STKContentStoreFetchDirectionOlder,
    STKContentStoreFetchDirectionNone
} STKContentStoreFetchDirection;

@interface STKContentStore : NSObject

+ (STKContentStore *)store;

- (void)fetchRecommendedHashtags:(NSString *)baseString
                      completion:(void (^)(NSArray *suggestions))block;

- (void)fetchPostsForUser:(STKUser *)u
               completion:(void (^)(NSArray *posts, NSError *err, BOOL moreComing))block;

- (void)addPostWithInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block;


- (void)fetchProfilePostsForProfile:(STKProfile *)prof
                        inDirection:(STKContentStoreFetchDirection)fetchDirection
                      referencePost:(STKPost *)referencePost
                         completion:(void (^)(NSArray *posts, NSError *err, BOOL moreComing))block;

- (void)fetchExplorePostsInDirection:(STKContentStoreFetchDirection)fetchDirection
                       referencePost:(STKPost *)referencePost
                          completion:(void (^)(NSArray *posts, NSError *err, BOOL moreComing))block;

- (void)fetchLocationNamesForCoordinate:(CLLocationCoordinate2D)coord
                             completion:(void (^)(NSArray *locations, NSError *err))block;

@end
