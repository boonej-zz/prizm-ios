//
//  STKUserStore.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKUser, STKPost, STKActivityItem, STKTrust;
@class ACAccount;

extern NSString * const STKUserStoreErrorDomain;
typedef enum {
    STKUserStoreErrorCodeMissingArguments, // @[arg0, ...]
    STKUserStoreErrorCodeNoAccount,
    STKUserStoreErrorCodeOAuth,
    STKUserStoreErrorCodeWrongAccount,
    STKUserStoreErrorCodeNoPassword
} STKUserStoreErrorCode;



extern NSString * const STKUserCoverPhotoURLStringKey;
extern NSString * const STKUserProfilePhotoURLStringKey;

@interface STKUserStore : NSObject

+ (STKUserStore *)store;

@property (nonatomic, strong) STKUser *currentUser;
@property (nonatomic) BOOL currentUserIsAuthorized;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block;

- (void)registerAccount:(STKUser *)info completion:(void (^)(STKUser *user, NSError *err))block;

// If returning STKUser, you are logged in as that user. If returning 2nd user, you have access to social account, but no Prism account exists.
- (void)connectWithFacebook:(void (^)(STKUser *existingUser, STKUser *facebookData, NSError *err))block;
- (void)connectWithTwitterAccount:(ACAccount *)acct completion:(void (^)(STKUser *existingUser, STKUser *registrationData, NSError *err))block;
- (void)connectWithGoogle:(void (^)(STKUser *existingUser, STKUser *registrationData, NSError *err))block;

// If accounts == 0, err is non-nil. Else, accounts is populated, err = nil
- (void)fetchAvailableTwitterAccounts:(void (^)(NSArray *accounts, NSError *err))block;


- (void)fetchUserDetails:(STKUser *)user completion:(void (^)(STKUser *u, NSError *err))block;
- (void)updateUserDetails:(STKUser *)user completion:(void (^)(STKUser *u, NSError *err))block;


- (void)searchUsersWithName:(NSString *)name completion:(void (^)(NSArray *profiles, NSError *err))block;

- (void)followUser:(STKUser *)user completion:(void (^)(id obj, NSError *err))block;
- (void)unfollowUser:(STKUser *)user completion:(void (^)(id obj, NSError *err))block;
- (void)fetchFollowersOfUser:(STKUser *)user completion:(void (^)(NSArray *followers, NSError *err))block;
- (void)fetchUsersFollowingOfUser:(STKUser *)user completion:(void (^)(NSArray *followers, NSError *err))block;

- (void)requestTrustForUser:(STKUser *)user completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)fetchRequestsForCurrentUser:(void (^)(NSArray *requests, NSError *err))block;
- (void)acceptTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)rejectTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)cancelTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block;
- (void)fetchTrustsForUser:(STKUser *)u completion:(void (^)(NSArray *trusts, NSError *err))block;

- (void)logout;


@end
