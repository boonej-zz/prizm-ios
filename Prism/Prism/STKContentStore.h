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


- (void)addPostWithInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block;

- (void)fetchFeedForUser:(STKUser *)u
             inDirection:(STKContentStoreFetchDirection)fetchDirection
           referencePost:(STKPost *)referencePost
              completion:(void (^)(NSArray *posts, NSError *err))block;

- (void)fetchProfilePostsForUser:(STKUser *)user
                     inDirection:(STKContentStoreFetchDirection)fetchDirection
                   referencePost:(STKPost *)referencePost
                      completion:(void (^)(NSArray *posts, NSError *err))block;

- (void)fetchExplorePostsInDirection:(STKContentStoreFetchDirection)fetchDirection
                       referencePost:(STKPost *)referencePost
                          completion:(void (^)(NSArray *posts, NSError *err))block;

- (void)fetchLocationNamesForCoordinate:(CLLocationCoordinate2D)coord
                             completion:(void (^)(NSArray *locations, NSError *err))block;

- (void)likePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
- (void)unlikePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;

@end
