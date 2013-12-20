//
//  STKUserStore.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKUser, STKPost, STKActivityItem, STKRequestItem, STKProfileInformation;

extern NSString * const STKUserStoreErrorDomain;
typedef enum {
    STKUserStoreErrorCodeMissingArguments, // @[arg0, ...]
    STKUserStoreErrorCodeNoAccount,
    STKUserStoreErrorCodeOAuth
} STKUserStoreErrorCode;

extern NSString * const STKLookupTypeGender;
extern NSString * const STKLookupTypeSocial;

extern NSString * const STKUserStoreTransparentLoginFailedNotification;

@interface STKUserStore : NSObject

+ (STKUserStore *)store;

@property (nonatomic, strong) STKUser *currentUser;

- (NSString *)transformLookupValue:(NSString *)lookupValue forType:(NSString *)type;

- (void)fetchFeedForCurrentUser:(void (^)(NSArray *posts, NSError *error, BOOL moreComing))block;
- (void)fetchActivityForCurrentUser:(void (^)(NSArray *activity, NSError *error, BOOL moreComing))block;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block;

- (void)registerAccount:(STKProfileInformation *)info completion:(void (^)(STKUser *user, NSError *err))block;
- (void)fetchGoogleAccount:(void (^)(STKUser *existingUser, STKProfileInformation *googleData, NSError *err))block;
- (void)fetchFacebookAccount:(void (^)(STKUser *existingUser, STKProfileInformation *facebookData, NSError *err))block;
- (void)fetchTwitterAccount:(void (^)(STKUser *existingUser, STKProfileInformation *twitterData, NSError *err))block;

- (void)fetchRecommendedHashtags:(NSString *)hashtag completion:(void (^)(NSArray *hashtags, NSError *error))block;
@end
