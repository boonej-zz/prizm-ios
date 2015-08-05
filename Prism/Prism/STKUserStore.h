//
//  STKUserStore.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKTrust.h"

@class STKUser, STKPost, STKActivityItem, STKFetchDescription, STKOrganization, STKGroup, STKMessage, STKSurvey, STKQuestion;
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
extern NSString * const HAUserStoreInterestsKey;
extern NSString * const HAUserStoreActivityInsightKey;
extern NSString * const HAUserStoreActivityLuminaryPostKey ;
extern NSString * const HAUnreadMessagesUpdated;
extern NSString * const HAUnreadMessagesForGroupsKey;
extern NSString * const HAUnreadMessagesForOrgKey;

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
- (void)syncInterests;

- (void)switchToUser:(STKUser *)u;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block;
- (void)resetPasswordForEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *err))block;
- (void)changePasswordForEmail:(NSString *)email currentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword completion:(void (^)(NSError *err))block;

- (void)registerAccount:(STKUser *)info completion:(void (^)(STKUser *user, NSError *err))block;

// If returning STKUser, you are logged in as that user. If returning 2nd user, you have access to social account, but no Prism account exists.
- (void)connectWithFacebook:(void (^)(STKUser *existingUser, STKUser *facebookData, NSError *err))block;
- (void)connectWithTwitterAccount:(ACAccount *)acct completion:(void (^)(STKUser *existingUser, STKUser *registrationData, NSError *err))block;
- (void)connectWithGoogle:(void (^)(STKUser *existingUser, STKUser *registrationData, NSError *err))completionBlock processing:(void (^)())processingBlock;
//- (void)fetchInsightsForUser:(STKUser *)user
//            fetchDescription:(STKFetchDescription *)desc
//                  completion:(void (^)(NSArray *insights, NSError *err))block;


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
- (void)fetchInterests:(void (^)(NSArray * interests, NSError *err))block;
- (void)fetchOrganizationByCode:(NSString *)code completion:(void (^)(STKOrganization *organization, NSError *err))block;
- (STKOrganization *)getOrganizationByCode:(NSString *)code;
- (void)updateInterestsforUser:(STKUser *)user completion:(void(^)(STKUser *u, NSError *err))block;
- (void)fetchSuggestionsForUser:(STKUser *)user completion:(void(^)(NSArray *users, NSError *err))block;
- (NSArray *)fetchUserOrgs:(void (^)(NSArray *organizations, NSError *err))block;
- (NSArray *)fetchGroupsForOrganization:(STKOrganization *)org completion:(void (^)(NSArray *groups, NSError *err))block;
- (NSArray *)fetchMessagesForOrganization:(STKOrganization *)organization group:(STKGroup *)group completion:(void (^)(NSArray *messages, NSError *err))block;
- (void)fetchLatestMessagesForOrganization:(STKOrganization *)organization group:(STKGroup *)group date:(NSDate *)date completion:(void (^)(NSArray *messages, NSError *err))block;
- (void)fetchOlderMessagesForOrganization:(STKOrganization *)organization group:(STKGroup *)group date:(NSDate *)date completion:(void (^)(NSArray *messages, NSError *err))block;
- (void)likeMessage:(STKMessage *)message completion:(void (^)(STKMessage *message, NSError *err))block;
- (void)unlikeMessage:(STKMessage *)message completion:(void (^)(STKMessage *message, NSError *err))block;

- (void)postMessage:(NSString*)message toGroup:(STKGroup *)group organization:(STKOrganization *)organization completion:(void (^)(STKMessage *message, NSError *err))block;
- (void)fetchMembersForOrganization:(STKOrganization *)organization completion:(void (^)(NSArray *messages, NSError *err))block;
- (NSArray *)getMembersForOrganization:(STKOrganization *)organization group:(STKGroup *)group;
- (void)editMessage:(STKMessage *)message completion:(void (^)(STKMessage *message, NSError *err))block;
- (void)deleteMessage:(STKMessage *)message completion:(void (^)(NSError *err))block;
- (void)createGroup:(NSString *)name forOrganization:(STKOrganization *)organization withDescription:(NSString *)description leader:(NSString *)leader member:(NSArray *)members completion:(void (^)(id data, NSError *error))block;
- (void)deleteGroup:(STKGroup *)group completion:(void (^)(id data, NSError *error))block;
- (void)editGroup:(STKGroup *)group name:(NSString *)name description:(NSString *)description leader:(NSString *)leader completion:(void (^)(id data, NSError *error))block;
- (void)editMembers:(NSArray *)members forGroup:(STKGroup *)group completion:(void (^)(id data, NSError *err))block;
- (void)removeUser:(STKUser *)user fromGroup:(STKGroup *)group completion:(void (^)(id data, NSError *err))block;
- (void)fetchUpdatedMessagesForOrganization:(STKOrganization *)organization group:(STKGroup *)group completion:(void (^)(NSArray *messages, NSError *err))block;
- (void)muteGroup:(STKGroup *)group muted:(BOOL)muted  completion:(void (^)(id data, NSError *error))block;
- (void)muteOrganization:(STKOrganization *)organization muted:(BOOL)muted completion:(void (^)(id, NSError *))block;
- (void)fetchUnreadCountForOrganization:(STKOrganization *)organization group:(STKGroup *)group completion:(void (^)(id obj, NSError *err))block;
- (void)postMessageImage:(NSString*)imageURL toGroup:(STKGroup *)group organization:(STKOrganization *)organization completion:(void (^)(STKMessage *message, NSError *err))block;
- (void)submitParentConsent:(NSDictionary *)parent forUser:(STKUser *)user completion:(void(^)(STKUser *user, NSError *err))block;
- (void)fetchPendingSurveysForUser:(STKUser *) user completion:(void (^)(NSArray * surveys, NSError *err))block;
- (void)submitSurveyAnswerForUser:(STKUser *)user question:(STKQuestion *)q value:(NSInteger)v completion:(void (^)(STKQuestion * question, NSError *err))block;
- (void)finalizeSurveyForUser:(STKUser *)user survey:(STKSurvey *)s completion:(void (^)(STKSurvey * survey, NSError *err))block;
@end
