//
//  STKUserStore.m
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKUserStore.h"
#import "STKUser.h"
#import "STKActivityItem.h"
#import "STKRequestItem.h"
#import "STKPost.h"
#import "STKConnection.h"
#import "STKUser.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "OAuthCore.h"
#import "NSError+STKConnection.h"
#import "STKSecurePassword.h"
#import "STKBaseStore.h"
#import "STKTrust.h"

NSString * const STKUserStoreErrorDomain = @"STKUserStoreErrorDomain";

NSString * const STKUserStoreCurrentUserKey = @"com.higheraltitude.prism.currentUser";

NSString * const STKUserStoreExternalCredentialGoogleClientID = @"945478453792.apps.googleusercontent.com";
NSString * const STKUserStoreExternalCredentialFacebookAppID = @"744512878911220";
NSString * const STKUserStoreExternalCredentialTwitterTokenSecret = @"tYnRjsX7toPoFAmRQnFOen8W3BsyJ2irnfmNYAIZwFAxd";
NSString * const STKUserStoreExternalCredentialTwitterConsumerKey = @"Ru65wMMNzljgbdZxie6okg";
//@"B8y2wlENU9eQCV2FO2s3rg";
NSString * const STKUserStoreExternalCredentialTwitterConsumerSecret = @"sJHdOEwTXQDO2y7nEjeHRdt8gX0TUhirOSNk32o";
//@"XKWgxHrWgE8sfnFv7IcrgcvLM6XFZdBGmQexnzwFo";

NSString * const STKUserEndpointUser = @"/users";
NSString * const STKUserEndpointLogin = @"/oauth2/login";

@import CoreData;
@import Accounts;
@import Social;

@interface STKUserStore () <GPPSignInDelegate>

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, copy) void (^googlePlusAuthenticationBlock)(GTMOAuth2Authentication *auth, NSError *err);


@end

@implementation STKUserStore
@synthesize currentUser = _currentUser;

+ (STKUserStore *)store
{
    static STKUserStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKUserStore alloc] init];
    });
    return store;
}


- (NSURLSession *)session
{
    return [[STKBaseStore store] session];
}

- (NSError *)errorForCode:(STKUserStoreErrorCode)code data:(id)data
{
    if(code == STKUserStoreErrorCodeMissingArguments) {
        return [NSError errorWithDomain:STKUserStoreErrorDomain code:code userInfo:@{@"missing arguments" : data}];
    }
    
    return [NSError errorWithDomain:STKUserStoreErrorDomain code:code userInfo:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectionDidFailAuthorization:)
                                                     name:STKConnectionUnauthorizedNotification
                                                   object:nil];
    }
    return self;
}

- (void)logout
{
    [self setCurrentUserIsAuthorized:NO];
    [self setCurrentUser:nil];
    [STKConnection cancelAllConnections];
    [[NSNotificationCenter defaultCenter] postNotificationName:STKSessionEndedNotification
                                                        object:nil
                                                      userInfo:@{STKSessionEndedReasonKey : STKSessionEndedLogoutValue}];

}



- (void)connectionDidFailAuthorization:(NSNotification *)note
{
    [self setCurrentUserIsAuthorized:NO];
    [self setCurrentUser:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STKSessionEndedNotification
                                                        object:nil
                                                      userInfo:@{STKSessionEndedReasonKey : STKSessionEndedAuthenticationValue}];

}

- (void)authenticateUser:(STKUser *)u
{
    [self setCurrentUser:u];
    [self setCurrentUserIsAuthorized:YES];
}

- (NSString *)cachePathForUserID:(NSString *)userID
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *userCachePath = [cachePath stringByAppendingPathComponent:@"users"];
    [[NSFileManager defaultManager] createDirectoryAtPath:userCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [userCachePath stringByAppendingPathComponent:userID];
}

- (void)setCurrentUser:(STKUser *)currentUser
{
    _currentUser = currentUser;
    
    if(currentUser) {
        [NSKeyedArchiver archiveRootObject:_currentUser toFile:[self cachePathForUserID:[_currentUser userID]]];
        [[NSUserDefaults standardUserDefaults] setObject:[currentUser userID]
                                                  forKey:STKUserStoreCurrentUserKey];
    } else {
        // Get rid of any pending requests, because this user no longer is any good
      //  [[self authorizedRequestQueue] removeAllObjects];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STKUserStoreCurrentUserKey];
    }
}

- (STKUser *)currentUser
{
    if(!_currentUser) {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:STKUserStoreCurrentUserKey];
        if(currentUserID) {
            STKUser *u = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForUserID:currentUserID]];
            if(u) {
                _currentUser = u;
                [self attemptTransparentLoginWithUser:_currentUser];
            }
        }
    }
    
    return _currentUser;
}

- (void)updateUserDetails:(STKUser *)user completion:(void (^)(STKUser *u, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[user userID]]];

        [c addQueryObject:user
              missingKeys:nil
               withKeyMap:@{@"firstName" : @"first_name",
                            @"lastName" : @"last_name",
                            @"gender" : @"gender",
                            @"zipCode" : @"zip_postal",
                            @"city" : @"city",
                            @"state" : @"state",
                            @"coverPhotoPath" : STKUserCoverPhotoURLStringKey,
                            @"profilePhotoPath" : STKUserProfilePhotoURLStringKey,
                            @"birthday" : ^(id value) {
                                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                [df setDateFormat:@"MM-dd-yyyy"];
                                return @{@"birthday" : [df stringFromDate:value]};
                            },
                            @"website" : @"website",
                            @"blurb" : @"info"
        }];
        
        [c setModelGraph:@[user]];
        [c putWithSession:[self session] completionBlock:^(STKUser *user, NSError *err) {
            
            block(user, err);
        }];
    }];
}

- (void)fetchUserDetails:(STKUser *)user completion:(void (^)(STKUser *u, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[user userID]]];
        [c addQueryValue:[[self currentUser] userID] forKey:@"creator"];
        [c setModelGraph:@[user]];
        
        [c getWithSession:[self session] completionBlock:^(STKUser *user, NSError *err) {

            block(user, err);
        }];
    }];
}

- (void)searchUsersWithName:(NSString *)name completion:(void (^)(NSArray *profiles, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c addQueryValue:@"30" forKey:@"limit"];
        [c addQueryValue:name forKey:@"name"];
        
        [c setModelGraph:@[[STKUser class]]];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *profiles, NSError *err) {
            if(!err) {
                block(profiles, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (void)followUser:(STKUser *)user completion:(void (^)(id obj, NSError *err))block
{
    [user setIsFollowedByCurrentUser:YES];
    [user setFollowerCount:[user followerCount] + 1];
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            [user setIsFollowedByCurrentUser:NO];
            [user setFollowerCount:[user followerCount] - 1];

            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[user userID], @"follow"]];
        [c addQueryValue:[[self currentUser] userID] forKey:@"creator"];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [user setIsFollowedByCurrentUser:NO];
                [user setFollowerCount:[user followerCount] - 1];
            }
            block(nil, err);
        }];
    }];
}

- (void)unfollowUser:(STKUser *)user completion:(void (^)(id obj, NSError *err))block
{
    [user setIsFollowedByCurrentUser:NO];
    [user setFollowerCount:[user followerCount] - 1];

    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            [user setFollowerCount:[user followerCount] + 1];
            [user setIsFollowedByCurrentUser:YES];

            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[user userID], @"unfollow"]];
        [c addQueryValue:[[self currentUser] userID] forKey:@"creator"];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [user setFollowerCount:[user followerCount] + 1];
                [user setIsFollowedByCurrentUser:YES];
            }
            block(nil, err);
        }];
    }];
}

- (void)fetchFollowersOfUser:(STKUser *)user completion:(void (^)(NSArray *followers, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[user userID], @"followers"]];
        [c setModelGraph:@[[STKUser class]]];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            block(obj, err);
        }];
    }];
}

- (void)fetchUsersFollowingOfUser:(STKUser *)user completion:(void (^)(NSArray *followers, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[user userID], @"following"]];
        [c setModelGraph:@[[STKUser class]]];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            block(obj, err);
        }];
    }];
}

- (void)requestTrustForUser:(STKUser *)user completion:(void (^)(STKTrust *requestItem, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[user userID], @"trusts"]];
        [c addQueryValue:[[self currentUser] userID] forKey:@"creator"];

        STKTrust *t = [[STKTrust alloc] init];
        [t setOtherUser:[self currentUser]];
        [t setStatus:STKRequestStatusPending];
        [t setOwningUser:user];
        [[user trusts] addObject:t];
        
        [c setModelGraph:@[t]];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [[user trusts] removeObjectIdenticalTo:t];
            }
            block(obj, err);
        }];
    }];
}

- (void)fetchRequestsForCurrentUser:(void (^)(NSArray *requests, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[[self currentUser] userID], @"trusts"]];
        //[c setShouldReturnArray:YES];
        [c setModelGraph:@[@{@"trusts" : @[[STKTrust class]]}]];
        [c getWithSession:[self session] completionBlock:^(NSDictionary *obj, NSError *err) {
            NSArray *reqs = [obj objectForKey:@"trusts"];
            for(STKTrust *t in reqs) {
                [t setOwningUser:[self currentUser]];
            }
            block(reqs, err);
        }];
    }];

}

- (void)acceptTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block
{
    [t setStatus:STKRequestStatusAccepted];
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            [t setStatus:STKRequestStatusPending];
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c addQueryValue:STKRequestStatusAccepted forKey:@"status"];
        [c setIdentifiers:@[[[t owningUser] userID], @"trusts", [t trustID]]];
        [c addQueryValue:[[t otherUser] userID] forKey:@"creator"];
        
        [c setModelGraph:@[[STKTrust class]]];
        [c putWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [t setStatus:STKRequestStatusPending];
            }
            block(obj, err);
        }];
    }];
    
}

- (void)rejectTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block
{
    NSString *prevState = [t status];
    [t setStatus:STKRequestStatusRejected];
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            [t setStatus:prevState];
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[[t owningUser] userID], @"trusts", [t trustID]]];
        [c addQueryValue:[[t otherUser] userID] forKey:@"creator"];
        [c addQueryValue:STKRequestStatusRejected forKey:@"status"];
        
        [c setModelGraph:@[[STKTrust class]]];
        [c putWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [t setStatus:prevState];
            }
            block(obj, err);
        }];
    }];
}

- (void)cancelTrustRequest:(STKTrust *)t completion:(void (^)(STKTrust *requestItem, NSError *err))block
{
    NSString *prevState = [t status];
    [t setStatus:STKRequestStatusCancelled];
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            [t setStatus:prevState];
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[[t owningUser] userID], @"trusts", [t trustID]]];
        [c addQueryValue:[[t otherUser] userID] forKey:@"creator"];
        [c addQueryValue:STKRequestStatusCancelled forKey:@"status"];

        
        [c setModelGraph:@[[STKTrust class]]];
        [c putWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [t setStatus:prevState];
            }
            block(obj, err);
        }];
    }];

}

- (void)fetchTrustsForUser:(STKUser *)u completion:(void (^)(NSArray *trusts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        [c setIdentifiers:@[[[self currentUser] userID], @"trusts"]];

        [c setModelGraph:@[@{@"trusts" : @[[STKTrust class]]}]];
        [c getWithSession:[self session] completionBlock:^(NSDictionary *obj, NSError *err) {
            
            NSArray *trusts = nil;
            if(!err) {
                trusts = [[obj objectForKey:@"trusts"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %@", STKRequestStatusAccepted]];
            }
            
            block(trusts, err);
        }];
    }];
}

#pragma mark Authentication Nonsense

- (void)executeSocialRequest:(SLRequest *)req forAccount:(ACAccount *)acct completion:(void (^)(id data, NSError *error))block
{
    [req setAccount:acct];
    
    NSURLRequest *urlRequest = [req preparedURLRequest];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               block(data, connectionError);
                           }];
}

#pragma mark Twitter

- (void)fetchAvailableTwitterAccounts:(void (^)(NSArray *accounts, NSError *err))block
{
    ACAccountType *type = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [[self accountStore] requestAccessToAccountsWithType:type
                                                 options:nil
                                              completion:^(BOOL granted, NSError *error) {
                                                  if(granted) {
                                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                          NSArray *accounts = [[self accountStore] accountsWithAccountType:type];
                                                          if([accounts count] > 0)
                                                              block([[self accountStore] accountsWithAccountType:type], nil);
                                                          else
                                                              block(nil, [self errorForCode:STKUserStoreErrorCodeNoAccount data:nil]);
                                                      }];
                                                  } else {
                                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                          block(nil, error);
                                                      }];
                                                  }
                                              }];
}

- (void)connectWithTwitterAccount:(ACAccount *)acct completion:(void (^)(STKUser *existingUser, STKUser *registrationData, NSError *err))block
{
    [self fetchTwitterAccessToken:acct completion:^(NSString *token, NSString *secret, NSError *tokenError) {
        if(!tokenError) {
            [self validateWithTwitterToken:token secret:secret completion:^(STKUser *user, NSError *valErr) {
                if(!valErr) {
                    [user setExternalServiceType:STKUserExternalSystemTwitter];
                    [user setAccountStoreID:[acct identifier]];
                    [self authenticateUser:user];
                    
                    block(user, nil, nil);
                } else {
                    if([valErr isConnectionError]) {
                        block(nil, nil, valErr);
                    } else {
                        // Return Twitter Information for Registration
                        [self fetchTwitterDataForAccount:acct completion:^(STKUser *profInfo, NSError *dataErr) {
                            if([dataErr isConnectionError]) {
                                block(nil, nil, dataErr);
                            } else {
                                [profInfo setToken:token];
                                [profInfo setSecret:secret];
                                block(nil, profInfo, dataErr);
                            }
                        }];
                    }
                }
            }];
        } else {
            // OAuth failed
            block(nil, nil, tokenError);
        }
    }];
}

- (void)validateWithTwitterToken:(NSString *)token secret:(NSString *)secret completion:(void (^)(STKUser *u, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointLogin];
        [c addQueryValue:token forKey:@"provider_token"];
        [c addQueryValue:secret forKey:@"provider_token_secret"];
        [c addQueryValue:STKUserExternalSystemTwitter forKey:@"provider"];
        
        if([self currentUser])
            [c setModelGraph:@[[self currentUser]]];
        else
            [c setModelGraph:@[[STKUser class]]];
        
        [c postWithSession:[self session]
           completionBlock:block];
    }];
}

- (void)fetchTwitterAccessToken:(ACAccount *)acct completion:(void (^)(NSString *token, NSString *tokenSecret, NSError *err))block
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
    NSData *bodyData = [@"x_auth_mode=reverse_auth" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authHeader = OAuthorizationHeader(url,
                                                @"POST",
                                                bodyData,
                                                STKUserStoreExternalCredentialTwitterConsumerKey,
                                                STKUserStoreExternalCredentialTwitterConsumerSecret,
                                                nil, nil);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:authHeader forHTTPHeaderField:@"Authorization"];
    [req setHTTPBody:bodyData];
    [req setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError) {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                      requestMethod:SLRequestMethodPOST
                                                                URL:[NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"]
                                                         parameters:@{@"x_reverse_auth_target" : STKUserStoreExternalCredentialTwitterConsumerKey,
                                                                      @"x_reverse_auth_parameters" : result}];
            [self executeSocialRequest:slRequest forAccount:acct completion:^(NSData *tokenResult, NSError *error) {
                if(!error) {
                    NSString *responseString = [[NSString alloc] initWithData:tokenResult encoding:NSUTF8StringEncoding];
                    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"&?([^=]*)=([^&]*)"
                                                                                    options:0 error:nil];
                    NSArray *matches = [exp matchesInString:responseString options:0 range:NSMakeRange(0, [responseString length])];
                    NSMutableDictionary *values = [NSMutableDictionary dictionary];
                    for(NSTextCheckingResult *match in matches) {
                        if([match numberOfRanges] == 3) {
                            NSString *key = [responseString substringWithRange:[match rangeAtIndex:1]];
                            NSString *val = [responseString substringWithRange:[match rangeAtIndex:2]];
                            [values setObject:val forKey:key];
                        }
                    }
                    NSString *token = [values objectForKey:@"oauth_token"];
                    NSString *secret = [values objectForKey:@"oauth_token_secret"];
                    if(token && secret) {
                        block(token, secret, nil);
                    } else {
                        // Failed because there wasn't token data
                        block(nil, nil, [self errorForCode:STKUserStoreErrorCodeOAuth data:nil]);
                    }
                } else {
                    // Failed getting token
                    block(nil, nil, [self errorForCode:STKUserStoreErrorCodeOAuth data:nil]);
                }
            }];
        } else {
            // Failed Sending oauth
            block(nil, nil, connectionError);
        }
    }];
}

- (void)fetchTwitterDataForAccount:(ACAccount *)acct completion:(void (^)(STKUser *acct, NSError *err))block
{
    NSString *requestString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/lookup.json?screen_name=%@", [acct username]];
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                        requestMethod:SLRequestMethodGET
                                                  URL:[NSURL URLWithString:requestString]
                                           parameters:nil];
    [self executeSocialRequest:req forAccount:acct completion:^(NSData *userData, NSError *userError) {
        if(!userError && userData) {
            NSArray *a = [NSJSONSerialization JSONObjectWithData:userData options:0 error:nil];
            
            STKUser *pi = [[STKUser alloc] init];
            [pi setValuesFromTwitter:a];
            [pi setAccountStoreID:[acct identifier]];
            
            SLRequest *profReq = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:[NSURL URLWithString:@"https://api.twitter.com/1/users/profile_image"]
                                                       parameters:@{@"screen_name" : [acct username], @"size" : @"bigger"}];
            [self executeSocialRequest:profReq forAccount:acct completion:^(NSData *profData, NSError *profError) {
                if(!profError) {
                    [pi setProfilePhoto:[UIImage imageWithData:profData]];
                }
                
                SLRequest *coverReq = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/profile_banner.json"]
                                                            parameters:@{@"screen_name" : [acct username]}];
                [self executeSocialRequest:coverReq forAccount:acct completion:^(NSData *coverData, NSError *coverError) {
                    if(!coverError) {
                        NSDictionary *coverDict = [NSJSONSerialization JSONObjectWithData:coverData options:0 error:nil];
                        NSString *urlString = [coverDict valueForKeyPath:@"sizes.mobile_retina.url"];
                        [pi setCoverPhotoPath:urlString];
                    }
                    block(pi, nil);
                }];
            }];
        } else {
            block(nil, userError);
        }
        
    }];
}


#pragma mark Facebook

- (void)connectWithFacebook:(void (^)(STKUser *existingUser, STKUser *facebookData, NSError *err))block
{
    [self fetchFacebookAccountWithCompletion:^(ACAccount *acct, NSError *err) {
        if(!err) {
            [self validateWithFacebook:[[acct credential] oauthToken]
                            completion:^(STKUser *user, NSError *valError) {
                if(!valError) {
                    [user setExternalServiceType:STKUserExternalSystemFacebook];
                    [user setAccountStoreID:[acct identifier]];

                    [self authenticateUser:user];
                    
                    block(user, nil, nil);
                } else {
                    if(![[[valError userInfo] objectForKey:@"error"] isEqualToString:STKErrorUserDoesNotExist]) {
                        block(nil, nil, valError);
                    } else {
                        // Fallback to registration
                        [self fetchFacebookDataForAccount:acct completion:^(STKUser *profInfo, NSError *dataErr) {
                            if([dataErr isConnectionError]) {
                                block(nil, nil, dataErr);
                            } else {
                                [profInfo setToken:[[acct credential] oauthToken]];
                                block(nil, profInfo, dataErr);
                            }
                        }];
                    }
                }
            }];
        } else {
            block(nil, nil, err);
        }
    }];
}

- (void)fetchFacebookAccountWithCompletion:(void (^)(ACAccount *acct, NSError *err))block
{
    ACAccountType *type = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [[self accountStore] requestAccessToAccountsWithType:type options:@{
                                                                        ACFacebookAppIdKey : STKUserStoreExternalCredentialFacebookAppID,
                                                                        ACFacebookPermissionsKey : @[
                                                                                @"email",
                                                                                @"user_birthday",
                                                                                @"user_education_history",
                                                                                @"user_hometown",
                                                                                @"user_location",
                                                                                @"user_photos",
                                                                                @"user_religion_politics"
                                                                            ]
                                                                        }
                                              completion:^(BOOL granted, NSError *error) {
                                                  if(granted) {
                                                      NSArray *accounts = [[self accountStore] accountsWithAccountType:type];

                                                      if([accounts count] == 1) {
                                                          ACAccount *acct = [accounts firstObject];
                                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                              block(acct, nil);
                                                          }];
                                                      } else {
                                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                              block(nil, [self errorForCode:STKUserStoreErrorCodeNoAccount data:nil]);
                                                          }];
                                                      }
                                                  } else {
                                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                          block(nil, error);
                                                      }];
                                                  }
                                              }];
}

- (void)validateWithFacebook:(NSString *)oauthToken completion:(void (^)(STKUser *u, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointLogin];
        [c addQueryValue:oauthToken forKey:@"provider_token"];
        [c addQueryValue:STKUserExternalSystemFacebook forKey:@"provider"];
        if([self currentUser])
            [c setModelGraph:@[[self currentUser]]];
        else
            [c setModelGraph:@[[STKUser class]]];
        [c postWithSession:[self session] completionBlock:block];
    }];
}

- (void)fetchFacebookDataForAccount:(ACAccount *)acct completion:(void (^)(STKUser *acct, NSError *err))block
{
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                        requestMethod:SLRequestMethodGET
                                                  URL:[NSURL URLWithString:@"https://graph.facebook.com/me"]
                                           parameters:nil];
    [self executeSocialRequest:req forAccount:acct completion:^(NSData *userData, NSError *userError) {
        if(!userError && userData) {
            NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:userData options:0 error:nil];
            
            STKUser *pi = [[STKUser alloc] init];
            [pi setValuesFromFacebook:userDict];
            [pi setToken:[[acct credential] oauthToken]];
            [pi setAccountStoreID:[acct identifier]];
            
            SLRequest *profilePicReq = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                          requestMethod:SLRequestMethodGET
                                                                    URL:[NSURL URLWithString:@"https://graph.facebook.com/me/picture"]
                                                             parameters:@{@"type" : @"large", @"access_token" : [[acct credential] oauthToken]}];
            [self executeSocialRequest:profilePicReq forAccount:acct completion:^(NSData *picData, NSError *picError) {
                if(!picError && picData) {
                    UIImage *image = [UIImage imageWithData:picData];
                    [pi setProfilePhoto:image];
                }
                
                SLRequest *coverPicReq = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                            requestMethod:SLRequestMethodGET
                                                                      URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me"]]
                                                               parameters:@{@"fields" : @"cover", @"access_token" : [[acct credential] oauthToken]}];
                [self executeSocialRequest:coverPicReq forAccount:acct completion:^(NSData *coverData, NSError *coverError) {
                    if(!coverError && coverData) {
                        NSDictionary *coverDict = [NSJSONSerialization JSONObjectWithData:coverData options:0 error:nil];
                        NSString *source = [coverDict valueForKeyPath:@"cover.source"];
                        [pi setCoverPhotoPath:source];
                    }
                    
                    block(pi, nil);
                }];
                
            }];
        } else {
            block(nil, userError);
        }
    }];
}

#pragma mark Google

- (void)connectWithGoogle:(void (^)(STKUser *, STKUser *, NSError *))block
{
    [self fetchGoogleAccount:^(GTMOAuth2Authentication *auth, NSError *err) {
        if(!err) {
            [self validateWithGoogle:[auth accessToken] completion:^(STKUser *u, NSError *err) {
                if(!err) {
                    [u setExternalServiceType:STKUserExternalSystemGoogle];

                    [self authenticateUser:u];
                    
                    block(u, nil, nil);
                } else {
                    if([err isConnectionError]) {
                        block(nil, nil, err);
                    } else {
                        [self fetchGoogleDataForAuth:auth completion:^(STKUser *pi, NSError *err) {
                            if(!err)
                                block(nil, pi, nil);
                            else
                                block(nil, nil, err);
                        }];
                    }
                }
            }];
        } else {
            block(nil, nil, err);
        }
    }];
}

- (void)fetchGoogleAccount:(void (^)(GTMOAuth2Authentication *auth, NSError *err))block
{
    [self setGooglePlusAuthenticationBlock:block];
    
    [[GPPSignIn sharedInstance] setScopes:@[kGTLAuthScopePlusLogin, kGTLAuthScopePlusMe]];
    [[GPPSignIn sharedInstance] setShouldFetchGooglePlusUser:YES];
    [[GPPSignIn sharedInstance] setShouldFetchGoogleUserEmail:YES];
    [[GPPSignIn sharedInstance] setShouldFetchGoogleUserID:YES];
    [[GPPSignIn sharedInstance] setClientID:STKUserStoreExternalCredentialGoogleClientID];
    [[GPPSignIn sharedInstance] setDelegate:self];
    
    GPPSignInButton *b = [[GPPSignInButton alloc] init];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}


- (void)validateWithGoogle:(NSString *)token completion:(void (^)(STKUser *, NSError *))block
{/*
    STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointValidateGoogle];
    [c addQueryValue:token forKey:@"ext_token"];
    [c setEntityName:@"STKUser"];
    [c setExistingMatchMap:@{@"userID" : @"entity"}];
    [c getWithSession:[self session] completionBlock:block];*/
}

- (void)fetchGoogleDataForAuth:(GTMOAuth2Authentication *)auth completion:(void (^)(STKUser *pi, NSError *err))block
{
    STKUser *pi = [[STKUser alloc] init];
    [pi setEmail:[auth userEmail]];
    [pi setToken:[auth accessToken]];
    
    GTLServicePlus *service = [[GTLServicePlus alloc] init];
    [service setAuthorizer:auth];
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, GTLPlusPerson *object, NSError *queryError) {
            if(!queryError) {
                [pi setValuesFromGooglePlus:object];
                block(pi, nil);
            } else {
                block(nil, queryError);
            }
        }];
}


- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error
{
    [self googlePlusAuthenticationBlock](auth, error);
    [self setGooglePlusAuthenticationBlock:nil];
}

#pragma mark Standard

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block
{
    [self validateWithEmail:email password:password completion:^(STKUser *user, NSError *err) {
        if(!err) {
            STKSecurityStorePassword([user email], password);
            
            [self authenticateUser:user];

            block(user, nil);
        } else {
            block(nil, err);
        }
    }];
}

- (void)validateWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointLogin];
        [c addQueryValue:email forKey:@"email"];
        [c addQueryValue:password forKey:@"password"];
        
        if([self currentUser])
            [c setModelGraph:@[[self currentUser]]];
        else
            [c setModelGraph:@[[STKUser class]]];
        
        [c postWithSession:[self session]
           completionBlock:block];
    }];
}

#pragma mark Uniform

- (void)registerAccount:(STKUser *)info completion:(void (^)(STKUser *user, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKUserEndpointUser];
        
        NSArray *missingKeys = nil;
        BOOL verified = [c addQueryObject:info
                              missingKeys:&missingKeys
                               withKeyMap:@{@"firstName" : @"first_name",
                                            @"lastName" : @"last_name",
                                            @"email" : @"email",
                                            @"gender" : @"gender",
                                            @"zipCode" : @"zip_postal",
                                            @"city" : @"city",
                                            @"state" : @"state",
                                            @"coverPhotoPath" : STKUserCoverPhotoURLStringKey,
                                            @"profilePhotoPath" : STKUserProfilePhotoURLStringKey,
                                            @"birthday" : ^(id value) {
                                                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                                    [df setDateFormat:@"MM-dd-yyyy"];
                                                    return @{@"birthday" : [df stringFromDate:value]};
                                                }
                                            }];
        
        if(!verified) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                block(nil, [self errorForCode:STKUserStoreErrorCodeMissingArguments
                                         data:missingKeys]);
            }];
            return;
        }
        
        if([info externalServiceType] && [info externalServiceID]) {
            [c addQueryObject:info missingKeys:nil withKeyMap:@{@"externalServiceID" : @"provider_id",
                                                                @"externalServiceType" : @"provider",
                                                                @"token" : @"provider_token"}];
            if([[info externalServiceType] isEqualToString:STKUserExternalSystemTwitter]) {
                [c addQueryValue:[info secret] forKey:@"provider_token_secret"];
            }
        } else if([info password]) {
            [c addQueryObject:info missingKeys:nil withKeyMap:@{@"password" : @"password"}];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                block(nil, [self errorForCode:STKUserStoreErrorCodeMissingArguments
                                         data:@[@"password", @"externalServiceType", @"externalServiceID"]]);
            }];
            return;
        }
        
        [c setModelGraph:@[[STKUser class]]];
        
        [c postWithSession:[self session] completionBlock:^(STKUser *registeredUser, NSError *err) {
            if(!err) {
                void (^validationBlock)(STKUser *, NSError *) = ^(STKUser *u, NSError *valErr) {
                    if(!valErr) {
                        if([info password]) {
                            STKSecurityStorePassword([u email], [info password]);
                        } /*else {
                            [u setExternalServiceType:[info externalService]];
                            [u setAccountStoreID:[info accountStoreID]];
                        }*/
                        [self authenticateUser:u];
                        
                        block(u, nil);
                    } else {
                        block(nil, valErr);
                    }
                };
                
                // Now let us authenticate
                if([[info externalServiceType] isEqualToString:STKUserExternalSystemGoogle]) {
                    [self validateWithGoogle:[info token] completion:validationBlock];
                } else if([[info externalServiceType] isEqualToString:STKUserExternalSystemFacebook]) {
                    validationBlock(registeredUser, nil);
                } else if([[info externalServiceType] isEqualToString:STKUserExternalSystemTwitter]) {
                    validationBlock(registeredUser, nil);
                } else {
                    validationBlock(registeredUser, nil);
                }
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (void)attemptTransparentLoginWithUser:(STKUser *)u
{
    if(!u)
        return;
    
    void (^validationBlock)(STKUser *, NSError *) = ^(STKUser *u, NSError *valErr) {
        if(!valErr) {
            [self authenticateUser:u];
        } else {
            [self setCurrentUser:nil];
    
            if([valErr isConnectionError]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:STKSessionEndedNotification
                                                                    object:nil
                                                                  userInfo:@{STKSessionEndedReasonKey : STKSessionEndedConnectionValue,
                                                                             @"error" : valErr}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:STKSessionEndedNotification
                                                                    object:nil
                                                                  userInfo:@{STKSessionEndedReasonKey : STKSessionEndedAuthenticationValue,
                                                                             @"error" : valErr}];
            }
        }
    };
    
    NSString *serviceType = [u externalServiceType];
    if([serviceType isEqualToString:STKUserExternalSystemFacebook]) {
        [self fetchFacebookAccountWithCompletion:^(ACAccount *acct, NSError *err) {
            if([[acct identifier] isEqualToString:[u accountStoreID]]) {
                [self validateWithFacebook:[[acct credential] oauthToken] completion:^(STKUser *u, NSError *err) {
                    validationBlock(u, err);
                }];
            } else {
                validationBlock(nil, [self errorForCode:STKUserStoreErrorCodeWrongAccount data:nil]);
            }
        }];
    } else if([serviceType isEqualToString:STKUserExternalSystemGoogle]) {
        [self fetchGoogleAccount:^(GTMOAuth2Authentication *auth, NSError *err) {
            if(!err) {
                [self validateWithGoogle:[auth accessToken] completion:^(STKUser *u, NSError *err) {
                    if(!err) {
                        validationBlock(u, err);
                    } else {
                        validationBlock(nil, err);
                    }
                }];
            } else {
                validationBlock(nil, err);
            }
        }];
    } else if([serviceType isEqualToString:STKUserExternalSystemTwitter]) {
        [self fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
            if(!err) {
                ACAccount *activeAccount = nil;
                for(ACAccount *acct in accounts) {
                    if([[acct identifier] isEqualToString:[u accountStoreID]]) {
                        activeAccount = acct;
                        break;
                    }
                }
                
                if(activeAccount) {
                    [self fetchTwitterAccessToken:activeAccount completion:^(NSString *token, NSString *tokenSecret, NSError *err) {
                        if(!err) {
                            [self validateWithTwitterToken:token secret:tokenSecret completion:^(STKUser *u, NSError *err) {
                                if(!err) {
                                    validationBlock(u, nil);
                                } else {
                                    // Spcific account could not be authoriized
                                    validationBlock(nil, err);
                                }
                            }];
                        } else {
                            // Could not authenticate via Twitter
                            validationBlock(nil, err);
                        }
                    }];
                } else {
                    // Could not find matching account
                    validationBlock(nil, [self errorForCode:STKUserStoreErrorCodeWrongAccount data:nil]);
                }
            } else {
                // Could not access accounts
                validationBlock(nil, err);
            }
        }];
    } else {
        // Via Email
        NSString *email = [u email];
        NSString *password = STKSecurityGetPassword(email);
        if(password) {
            [self validateWithEmail:email password:password completion:^(STKUser *user, NSError *err) {
                if(!err) {
                    validationBlock(user, nil);
                } else {
                    validationBlock(nil, err);
                }
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                validationBlock(nil, [self errorForCode:STKUserStoreErrorCodeNoPassword data:nil]);
            }];
        }
    }
    
    
}



@end
