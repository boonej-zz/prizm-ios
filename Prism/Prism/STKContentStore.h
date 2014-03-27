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

@class STKUser, STKPostComment;

extern NSString * const STKContentStoreErrorDomain;
typedef enum {
    STKContentStoreErrorCodeMissingArguments, // @[arg0, ...]
} STKContentStoreErrorCode;

typedef enum {
    STKContentStoreFetchDirectionNewer,
    STKContentStoreFetchDirectionOlder,
    STKContentStoreFetchDirectionNone
} STKContentStoreFetchDirection;

extern NSString * const STKContentStorePostDeletedNotification;
extern NSString * const STKContentStorePostDeletedKey;

@interface STKContentStore : NSObject

+ (STKContentStore *)store;

// Complete - introduce 'popularity'
- (void)fetchRecommendedHashtags:(NSString *)baseString
                      completion:(void (^)(NSArray *suggestions))block;


// Complete
- (void)addPostWithInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block;
// * Requires update to service to include post in response body
- (void)editPost:(STKPost *)p withInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block;

// Complete - Verify 'Older'
- (void)fetchFeedForUser:(STKUser *)u
             inDirection:(STKContentStoreFetchDirection)fetchDirection
           referencePost:(STKPost *)referencePost
              completion:(void (^)(NSArray *posts, NSError *err))block;

// Complete - Verify 'Older'
- (void)fetchProfilePostsForUser:(STKUser *)user
                     inDirection:(STKContentStoreFetchDirection)fetchDirection
                   referencePost:(STKPost *)referencePost
                      completion:(void (^)(NSArray *posts, NSError *err))block;

// Complete
- (void)fetchExplorePostsInDirection:(STKContentStoreFetchDirection)fetchDirection
                       referencePost:(STKPost *)referencePost
                              filter:(NSDictionary *)filterDict
                          completion:(void (^)(NSArray *posts, NSError *err))block;

// Complete
- (void)fetchExplorePostsInDirection:(STKContentStoreFetchDirection)fetchDirection
                       referencePost:(STKPost *)referencePost
                          completion:(void (^)(NSArray *posts, NSError *err))block;
// Complete
- (void)fetchPostsForLocationName:(NSString *)locationName
                        direction:(STKContentStoreFetchDirection)fetchDirection
                    referencePost:(STKPost *)referencePost
                       completion:(void (^)(NSArray *posts, NSError *err))block;
// Complete
- (void)fetchLocationNamesForCoordinate:(CLLocationCoordinate2D)coord
                             completion:(void (^)(NSArray *locations, NSError *err))block;

- (void)searchPostsForHashtag:(NSString *)hashTag
                   completion:(void (^)(NSArray *posts, NSError *err))block;


// Complete - Retest against Cached posts in home feed after reimping followers
- (void)likePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
// Complete - Retest against Cached posts in home feed after reimping followers
- (void)unlikePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
// Complete
- (void)deletePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
// Complete
- (void)flagPost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
// Complete - test against liking/unliking
- (void)fetchLikersForPost:(STKPost *)post completion:(void (^)(NSArray *likers, NSError *err))block;

// Complete
- (void)addComment:(NSString *)comment toPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block;
// Complete
- (void)fetchCommentsForPost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;

// Complete
- (void)likeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block;
// Complete
- (void)unlikeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block;
// Complete
- (void)deleteComment:(STKPostComment *)comment completion:(void (^)(STKPost *p, NSError *err))block;
// Complete
- (void)fetchLikersForComment:(STKPostComment *)postComment completion:(void (^)(NSArray *likers, NSError *err))block;

@end
