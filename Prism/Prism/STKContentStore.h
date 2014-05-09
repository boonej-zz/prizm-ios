//
//  STKContentStore.h
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPost.h"
#import "STKQueryObject.h"

@import CoreLocation;

@class STKUser, STKPostComment, STKFetchDescription;

extern NSString * const STKContentStoreErrorDomain;
typedef enum {
    STKContentStoreErrorCodeMissingArguments, // @[arg0, ...]
} STKContentStoreErrorCode;

extern NSString * const STKContentStorePostDeletedNotification;
extern NSString * const STKContentStorePostDeletedKey;


@interface STKContentStore : NSObject

+ (STKContentStore *)store;

- (void)fetchRecommendedHashtags:(NSString *)baseString
                      completion:(void (^)(NSArray *suggestions))block;

- (void)addPostWithInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block;
- (void)editPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block;
- (void)fetchPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block;

- (void)fetchFeedForUser:(STKUser *)u
        fetchDescription:(STKFetchDescription *)desc
              completion:(void (^)(NSArray *posts, NSError *err))block;

- (void)fetchProfilePostsForUser:(STKUser *)user
                fetchDescription:(STKFetchDescription *)desc
                      completion:(void (^)(NSArray *posts, NSError *err))block;

- (void)fetchExplorePostsWithFetchDescription:(STKFetchDescription *)desc
                                   completion:(void (^)(NSArray *posts, NSError *err))block;

- (void)fetchLocationNamesForCoordinate:(CLLocationCoordinate2D)coord
                             completion:(void (^)(NSArray *locations, NSError *err))block;

- (void)searchPostsForHashtag:(NSString *)hashTag
                   completion:(void (^)(NSArray *posts, NSError *err))block;


- (void)likePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
- (void)unlikePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
- (void)deletePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
- (void)flagPost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block;
- (void)fetchLikersForPost:(STKPost *)post completion:(void (^)(NSArray *likers, NSError *err))block;

- (void)addComment:(NSString *)comment toPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block;
- (void)fetchCommentsForPost:(STKPost *)post completion:(void (^)(NSArray *comments, NSError *err))block;

- (void)likeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block;
- (void)unlikeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block;
- (void)deleteComment:(STKPostComment *)comment completion:(void (^)(STKPost *p, NSError *err))block;
- (void)fetchLikersForComment:(STKPostComment *)postComment completion:(void (^)(NSArray *likers, NSError *err))block;

@end
