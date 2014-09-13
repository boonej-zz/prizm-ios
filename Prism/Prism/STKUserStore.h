//
//  STKUserStore.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKTrust.h"

@class STKUser, STKPost, STKActivityItem, STKFetchDescription;
@class ACAccount, ACAccountStore;

extern NSString * const STKUserStoreActivityUpdateNotification;
extern NSString * const STKUserStoreActivityUpdateCountKey;

extern NSString * const STKUserStoreCurrentUserChangedNotification;
extern NSString * const STKUserStoreErrorDomain;
extern NSString * const HAUserStoreActivityUserKey;
extern NSString * const HAUserStoreActivityLikeKey;
extern NSString * const HAUserStoreActivityTrustKey;
extern NSString * const HAUserStoreActivityCommentKey;
extern NSString * const HANotificationKeyUserLoggedOut;

typedef enum {
    STKUserStoreErrorCodeMissingArguments, // @[arg0, ...]
    STKUserStoreErrorCodeNoAccount,
    STKUserStoreErrorCodeOAuth,
    STKUserStoreErrorCodeWrongAccount,
    STKUserStoreErrorCodeNoPassword
} STKUserStoreErrorCode;


@interface STKUserStore : NSObject

+ (STKUserStore *)store;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) STKUser *currentUser;


- (void)updateDeviceTokenForCurrentUser:(NSData *)deviceToken;
- (void)markActivitiesAsRead;
- (NSArray *)loggedInUsers;

- (STKUser *)userForID:(NSString *)userID;

- (void)transferPostsFromSocialNetworks;
- (void)logout;

- (void)switchToUser:(STKUser *)u;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block;
- (void)resetPasswordForEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *err))block;

- (void)registerAccount:(STKUser *)info completion:(void (^)(STKUser *user, NSError *err))block;

// If returning STKUser, you are logged in as that user. If returning 2nd user, you have access to social account, but no Prism account exists.
- (void)connectWithFacebook:(void (^)(STKUser *existingUser, STKUser *facebookData, NSError *err))block;
- (void)connectWithTwitterAccount:(ACAccount *)acct completion:(void (^)(STKUser *existingUser, STKUser *registrationData, NSError *err))block;
- (void)connectWithGoogle:(void (^)(STKUser *existingUser, STKUser *registrationData, NSError *err))completionBlock processing:(void (^)())processingBlock;


// If accounts == 0, err is non-nil. Else, accounts is populated, err = nil
- (void)fetchAvailableTwitterAccounts:(void (^)(NSArray *accounts, NSError *err))block;
- (void)fetchTwitterAccessToken:(ACAccount *)acct completion:(void (^)(NSString *token, NSString *tokenSecret, NSError *err))block;

- (void)fetchUserDetails:(STKUser *)user additionalFields:(NSArray *)fields completion:(void (^)(STKUser *u, NSError *err))block;

- (void)updateUserDetails:(STKUser *)user completion:(void (^)(STKUser *u, NSError *err))block;

- (void)disableUser:(STKUser *)user completion:(void (^)(STKUser *u, NSError *err))block;

- (void)fetchTrustForUser:(STKUser *)user otherUser:(STKUser *)otherUser completion:(void (^)(STKTrust *t, NSError *err))block;

- (void)searchUsersWithName:(NSString *)name completion:(void (^)(NSArray *profiles, NSError *err))block;
- (void)searchUsersWithType:(NSString *)type completion:(void (^)(NSArray *profiles, NSError *err))block;

- (void)followUser:(STKUser *)user completion:(void (^)(id obj, NSError *err))block;
- (void)unfollowUser:(STKUser *)user completion:(void (^)(id obj, NSError *err))block;


- (void)fetchFollowersOfUser:(STKUser *)user completion:(void (^)(NSArray *followers, NSError *err))block;
- (void)fetchUsersFollowingOfUser:(STKUser *)user completion:(void (^)(NSArray *followers, NSError *err))block;
- (void)fetchTrustsForUser:(STKUser *)u fetchDescription:(STKFetchDescription *)fetchDescription completion:(void (^)(NSArray *trusts, NSError *err))block;

- (void)fetchActivityForUser:(STKUser *)u fetchDescription:(STKFetchDescription *)fetchDescription completion:(void (^)(NSArray *activities, NSError *err))block;

- (void)fetchTopTrustsForUser:(STKUser *)u completion:(void (^)(NSArray *trusts, NSError *err))block;
- (void)requestTrustForUser:(STKUser *)user completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)fetchRequestsForCurrentUserWithFetchDescription:(STKFetchDescription *)fetchDescription completion:(void (^)(NSArray *requests, NSError *err))block;
- (void)acceptTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)rejectTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)cancelTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)fetchTrustPostsForTrust:(STKTrust *)t type:(STKTrustPostType)type completion:(void (^)(NSArray *posts, NSError *err))block;
- (void)searchUserTrustsWithName:(NSString *)name completion:(void (^)(id data, NSError *error))block;
- (void)searchUserNotInTrustWithName:(NSString *)name completion:(void (^)(id data, NSError *error))block;
- (void)updateTrust:(STKTrust *)t toType:(NSString *)type completion:(void (^)(STKTrust *requestItem, NSError *err))block;

- (void)fetchGraphDataForWeek:(int)week inYear:(int)year previousWeekCount:(int)count completion:(void (^)(NSDictionary *weeks, NSError *err))block;
- (void)fetchLifetimeGraphDataWithCompletion:(void (^)(NSDictionary *data, NSError *err))block;
- (void)fetchHashtagsForPostTypesWithCompletion:(void (^)(NSDictionary *hashTags, NSError *err))block;


@end
