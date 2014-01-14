//
//  STKUserStore.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKUser, STKPost, STKActivityItem, STKRequestItem, STKProfileInformation;
@class ACAccount;

extern NSString * const STKUserStoreErrorDomain;
typedef enum {
    STKUserStoreErrorCodeMissingArguments, // @[arg0, ...]
    STKUserStoreErrorCodeNoAccount,
    STKUserStoreErrorCodeOAuth,
    STKUserStoreErrorCodeWrongAccount,
    STKUserStoreErrorCodeNoPassword
} STKUserStoreErrorCode;

extern NSString * const STKUserStoreTransparentLoginFailedNotification;
    extern NSString * const STKUserStoreTransparentLoginFailedReasonKey;
        extern NSString * const STKUserStoreTransparentLoginFailedConnectionValue;
        extern NSString * const STKUserStoreTransparentLoginFailedAuthenticationValue;

extern NSString * const STKUserStoreUserBecameUnauthorizedNotification;


extern NSString * const STKUserCoverPhotoURLStringKey;
extern NSString * const STKUserProfilePhotoURLStringKey;

@interface STKUserStore : NSObject

+ (STKUserStore *)store;

@property (nonatomic, strong) STKUser *currentUser;
@property (nonatomic) BOOL currentUserIsAuthorized;

- (void)executeAuthorizedRequest:(void (^)(void))request;

/*
- (void)fetchFeedForCurrentUser:(void (^)(NSArray *posts, NSError *error, BOOL moreComing))block;
- (void)fetchActivityForCurrentUser:(void (^)(NSArray *activity, NSError *error, BOOL moreComing))block;
- (void)fetchRecommendedHashtags:(NSString *)hashtag completion:(void (^)(NSArray *hashtags, NSError *error))block;
*/
- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block;

- (void)registerAccount:(STKProfileInformation *)info completion:(void (^)(STKUser *user, NSError *err))block;

// If returning STKUser, you are logged in as that user. If returning STKProfileInformation, you have access to social account, but no Prism account exists.
- (void)connectWithFacebook:(void (^)(STKUser *existingUser, STKProfileInformation *facebookData, NSError *err))block;
- (void)connectWithTwitterAccount:(ACAccount *)acct completion:(void (^)(STKUser *existingUser, STKProfileInformation *registrationData, NSError *err))block;
- (void)connectWithGoogle:(void (^)(STKUser *existingUser, STKProfileInformation *registrationData, NSError *err))block;

// If accounts == 0, err is non-nil. Else, accounts is populated, err = nil
- (void)fetchAvailableTwitterAccounts:(void (^)(NSArray *accounts, NSError *err))block;

- (void)fetchProfileForCurrentUser:(void (^)(STKUser *u, NSError *err))block;
- (void)updateCurrentProfileWithInformation:(NSDictionary *)info completion:(void (^)(STKUser *u, NSError *err))block;

- (void)logout;


@end
