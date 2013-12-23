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
#import "STKProfileInformation.h"
#import "STKConnection.h"
#import "STKUser.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "OAuthCore.h"
#import "NSError+STKConnection.h"
#import "STKSecurePassword.h"

// To erase DB data:
// curl prism.neadwerx.com/common/ajax/delete_all_entities_and_data.php

NSString * const STKUserStoreErrorDomain = @"STKUserStoreErrorDomain";

NSString * const STKLookupTypeGender = @"STKGender";
NSString * const STKLookupTypeSocial = @"STKExternalSystem";

NSString * const STKUserStoreCurrentUserKey = @"com.higheraltitude.prism.currentUser";

NSString * const STKUserStoreExternalCredentialGoogleClientID = @"945478453792.apps.googleusercontent.com";
NSString * const STKUserStoreExternalCredentialFacebookAppID = @"744512878911220";
NSString * const STKUserStoreExternalCredentialTwitterTokenSecret = @"tYnRjsX7toPoFAmRQnFOen8W3BsyJ2irnfmNYAIZwFAxd";
NSString * const STKUserStoreExternalCredentialTwitterConsumerKey = @"B8y2wlENU9eQCV2FO2s3rg";
NSString * const STKUserStoreExternalCredentialTwitterConsumerSecret = @"XKWgxHrWgE8sfnFv7IcrgcvLM6XFZdBGmQexnzwFo";

NSString * const STKUserBaseURLString = @"http://prism.neadwerx.com";
NSString * const STKUserEndpointRegister = @"/common/ajax/create_entity.php";
NSString * const STKUserEndpointValidateFacebook = @"/common/ajax/validate_facebook.php";
NSString * const STKUserEndpointValidateTwitter = @"/common/ajax/validate_twitter.php";
NSString * const STKUserEndpointValidateGoogle = @"/common/ajax/validate_google.php";
NSString * const STKUserEndpointValidateEmail = @"/common/ajax/validate_login.php";

NSString * const STKUserEndpointGenderList = @"/common/ajax/get_genders.php";
NSString * const STKUserEndpointSocialList = @"/common/ajax/get_external_systems.php";

NSString * const STKUserStoreTransparentLoginFailedNotification = @"STKUserStoreTransparentLoginFailedNotification";
NSString * const STKUserStoreTransparentLoginFailedReasonKey = @"STKUserStoreTransparentLoginFailedReasonKey";
NSString * const STKUserStoreTransparentLoginFailedConnectionValue = @"STKUserStoreTransparentLoginFailedConnectionValue";
NSString * const STKUserStoreTransparentLoginFailedAuthenticationValue = @"STKUserStoreTransparentLoginFailedAuthenticationValue";

@import CoreData;
@import Accounts;
@import Social;

@interface STKUserStore () <NSURLSessionDelegate, GPPSignInDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSURLSession *userSession;
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

+ (NSURL *)baseURL
{
    return [NSURL URLWithString:STKUserBaseURLString];
}

- (NSError *)errorForCode:(STKUserStoreErrorCode)code data:(id)data
{
    if(code == STKUserStoreErrorCodeMissingArguments) {
        return [NSError errorWithDomain:STKUserStoreErrorDomain code:code userInfo:@{@"missing arguments" : data}];
    }
    
    return [NSError errorWithDomain:STKUserStoreErrorDomain code:code userInfo:nil];
}

- (STKConnection *)connectionForEndpoint:(NSString *)endpoint
{
    STKConnection *c = [[STKConnection alloc] initWithBaseURL:[[self class] baseURL]
                                                     endpoint:endpoint];
    
    return c;
}


- (id)init
{
    self = [super init];
    if (self) {
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"User"
                                                                                                                withExtension:@"momd"]];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"user.db"];
        NSError *error = nil;
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[NSURL fileURLWithPath:dbPath]
                                    options:nil
                                      error:&error]) {
            [NSException raise:@"Open failed" format:@"Reason %@", [error localizedDescription]];
        }
        
        _context = [[NSManagedObjectContext alloc] init];
        [[self context] setPersistentStoreCoordinator:psc];
        [[self context] setUndoManager:nil];
        
        _accountStore = [[ACAccountStore alloc] init];
        
        _userSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
     
        
        [self fetchLookupValues];
        
        
      //  [self buildTemporaryData];
    }
    return self;
}

- (void)fetchLookupValues
{
    [self fetchLookupValuesForEntity:@"STKGender" endpoint:STKUserEndpointGenderList keyPath:@"genders.gender"];
    [self fetchLookupValuesForEntity:@"STKExternalSystem" endpoint:STKUserEndpointSocialList keyPath:@"external_systems.external_system"];
}

- (void)fetchLookupValuesForEntity:(NSString *)entity endpoint:(NSString *)endpoint keyPath:(NSString *)keyPath
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    NSString *keyGrouping = [keys objectAtIndex:0];
    NSString *keyName = [keys objectAtIndex:1];
    
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:entity];
    if([[[self context] executeFetchRequest:r error:nil] count] == 0) {
        STKConnection *c = [self connectionForEndpoint:endpoint];
        [c getWithSession:[self userSession]
          completionBlock:^(NSDictionary *lookupValues, NSError *err) {
              NSArray *allValues = [lookupValues objectForKey:keyGrouping];
              for(NSDictionary *value in allValues) {
                  NSManagedObject *o = [NSEntityDescription insertNewObjectForEntityForName:entity
                                                                     inManagedObjectContext:[self context]];
                  [o setValue:[value objectForKey:@"label"] forKey:@"label"];
                  [o setValue:[value objectForKey:keyName] forKey:@"identifier"];
              }
              [[self context] save:nil];
          }];
    }
}

- (void)setCurrentUser:(STKUser *)currentUser
{
    _currentUser = currentUser;
    if([currentUser userID]) {
        [[NSUserDefaults standardUserDefaults] setObject:[currentUser userID]
                                                  forKey:STKUserStoreCurrentUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STKUserStoreCurrentUserKey];
    }
    
}

- (STKUser *)currentUser
{
    if(!_currentUser) {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:STKUserStoreCurrentUserKey];
        if(currentUserID) {
            NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"STKUser"];
            [req setPredicate:[NSPredicate predicateWithFormat:@"userID == %@", currentUserID]];
            STKUser *u = [[[self context] executeFetchRequest:req error:nil] firstObject];
            if(u) {
                _currentUser = u;
                [self attemptTransparentLoginWithUser:_currentUser];
            }
        }
    }
    
    return _currentUser;
}


- (void)fetchFeedForCurrentUser:(void (^)(NSArray *posts, NSError *error, BOOL moreComing))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block([[[self currentUser] posts] array], nil, NO);
    }];
}

- (void)fetchActivityForCurrentUser:(void (^)(NSArray *activity, NSError *error, BOOL moreComing))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block([[[self currentUser] activityItems] array], nil, NO);
    }];
}

- (void)buildTemporaryData
{
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:@"STKUser"];
    NSArray *a = [[self context] executeFetchRequest:r error:nil];
    if([a count] > 0) {
        [self setCurrentUser:[a objectAtIndex:0]];
        return;
    }
    
    STKUser *u = [NSEntityDescription insertNewObjectForEntityForName:@"STKUser"
                                               inManagedObjectContext:[self context]];
    [u setUserID:0];
    [u setUserName:@"Cedric Rogers"];
    [u setEmail:@"cedric@higheraltitude.co"];
    [u setGender:@"Male"];
    
    [self setCurrentUser:u];
    
    // reuqestItes, activityItems, posts
    
    NSArray *authors = @[@"University of Wisconsin", @"Cedric Rogers", @"Joe Conway", @"Rovane Durso",
                         @"Facebook", @"North Carolina State", @"Emory"];
    NSArray *iconURLStrings = @[@"https://www.etsy.com/storque/media/bunker/2008/10/DU_Wisconsin_logo-tn.jpg",
                               @"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg",
                               @"http://stablekernel.com/images/joe.png",
                               @"https://pbs.twimg.com/profile_images/3500227034/2ad776b09c64e9ff677c91dd55a18472_bigger.jpeg",
                               @"http://marketingland.com/wp-content/ml-loads/2013/05/facebook-logo-new-300x300.png",
                               @"http://www.logotypes101.com/logos/953/28D5E04946B566AA97E4770658F48F55/NC_State_University1.png",
                               @"http://www.comacc.org/training/PublishingImages/Emory_Logo.jpg"];
                               
    NSArray *origins = @[@"Instagram", @"Facebook", @"Prism", @"Twitter"];
    NSArray *dates = @[[NSDate date], [NSDate dateWithTimeIntervalSinceNow:-100000], [NSDate dateWithTimeIntervalSinceNow:-2000]];
    NSArray *images = @[@"http://socialmediamamma.com/wp-content/uploads/2012/11/now-is-the-time-inspirational-quote-inspiring-quotes-www.socialmediamamma.com_.jpg",
                        @"http://socialmediamamma.com/wp-content/uploads/2012/11/dont-be-afraid-to-live-inspiring-quotes-Inspirational-quotes-Gaynor-Parke-www.socialmediamamma.com_.jpg"];
                        
    NSArray *hashTags = @[@"hash", @"tag", @"bar", @"foo", @"baz", @"school", @"inspiration"];
    
    srand((unsigned int)time(NULL));
    
    for(int i = 0; i < 10; i++) {
        STKPost *p = [NSEntityDescription insertNewObjectForEntityForName:@"STKPost"
                                                   inManagedObjectContext:[self context]];
        int idx = rand() % [authors count];
        [p setAuthorName:authors[idx]];
        [p setIconURLString:iconURLStrings[idx]];

        idx = rand() % [origins count];
        [p setPostOrigin:origins[idx]];
        
        [p setAuthorUserID:0];
        
        idx = rand() % [dates count];
        [p setDatePosted:dates[idx]];
        
        int count = rand() % 4;
        NSMutableArray *tags = [NSMutableArray array];
        for(int j = 0; j < count; j++) {
            idx = rand() % [hashTags count];
            [tags addObject:hashTags[idx]];
        }
        [p setHashTagsData:[NSJSONSerialization dataWithJSONObject:tags options:0 error:nil]];

        idx = rand() % [images count];
        [p setImageURLString:images[idx]];
        [p setUser:u];
    }
    
    for(int i = 0; i < 5; i++) {
        STKActivityItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"STKActivityItem"
                                                              inManagedObjectContext:[self context]];
        [item setUser:u];
        [item setUserID:0];
        [item setUserName:@"Cedric Rogers"];
        [item setProfileImageURLString:@"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg"];
        [item setRecent:(BOOL)(rand() % 2)];
        [item setType:(STKActivityItemType)(rand() % 5)];
        [item setReferenceImageURLString:images[rand() % [images count]]];
        [item setDate:dates[rand() % [dates count]]];
    }
    for(int i = 0; i < 5; i++) {
        STKRequestItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"STKRequestItem"
                                                              inManagedObjectContext:[self context]];
        [item setUser:u];
        [item setUserID:0];
        [item setUserName:@"Cedric Rogers"];
        [item setProfileImageURLString:@"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg"];
        [item setType:STKRequestItemTypeTrust];
        [item setDateReceived:dates[rand() % [dates count]]];
        if(rand() % 2 == 0) {
            [item setAccepted:(BOOL)(rand() % 2)];
            [item setDateConfirmed:dates[rand() % [dates count]]];
        }
        
    }
    [[self context] save:nil];
}

- (void)fetchRecommendedHashtags:(NSString *)hashtag completion:(void (^)(NSArray *hashtags, NSError *error))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block(@[hashtag,@"foo",@"bar",@"foobar"],nil);
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

- (void)connectWithTwitterAccount:(ACAccount *)acct completion:(void (^)(STKUser *existingUser, STKProfileInformation *registrationData, NSError *err))block
{
    [self fetchTwitterAccessToken:acct completion:^(NSString *token, NSString *secret, NSError *tokenError) {
        if(!tokenError) {
            [self validateWithTwitterToken:token secret:secret completion:^(STKUser *user, NSError *valErr) {
                if(!valErr) {
                    [self setCurrentUser:user];
                    [user setExternalServiceType:STKProfileInformationExternalServiceTwitter];
                    [user setAccountStoreID:[acct identifier]];
                    
                    [[self context] save:nil];
                    block(user, nil, nil);
                } else {
                    if([valErr isConnectionError]) {
                        block(nil, nil, valErr);
                    } else {
                        // Return Twitter Information for Registration
                        [self fetchTwitterDataForAccount:acct completion:^(STKProfileInformation *profInfo, NSError *dataErr) {
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
    STKConnection *c = [self connectionForEndpoint:STKUserEndpointValidateTwitter];
    [c addQueryValue:token forKey:@"ext_token"];
    [c addQueryValue:secret forKey:@"ext_token_secret"];
    [c setContext:[self context]];
    [c setEntityName:@"STKUser"];
    [c setExistingMatchMap:@{@"userID" : @"entity"}];
    [c getWithSession:[self userSession]
      completionBlock:block];
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

- (void)fetchTwitterDataForAccount:(ACAccount *)acct completion:(void (^)(STKProfileInformation *acct, NSError *err))block
{
    NSString *requestString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/lookup.json?screen_name=%@", [acct username]];
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                        requestMethod:SLRequestMethodGET
                                                  URL:[NSURL URLWithString:requestString]
                                           parameters:nil];
    [self executeSocialRequest:req forAccount:acct completion:^(NSData *userData, NSError *userError) {
        if(!userError && userData) {
            NSArray *a = [NSJSONSerialization JSONObjectWithData:userData options:0 error:nil];
            
            STKProfileInformation *pi = [[STKProfileInformation alloc] init];
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
                        [pi setCoverPhotoURLString:urlString];
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

- (void)connectWithFacebook:(void (^)(STKUser *existingUser, STKProfileInformation *facebookData, NSError *err))block
{
    [self fetchFacebookAccountWithCompletion:^(ACAccount *acct, NSError *err) {
        if(!err) {
            [self validateWithFacebook:[[acct credential] oauthToken] completion:^(STKUser *user, NSError *valError) {
                if(!valError) {
                    [self setCurrentUser:user];
                    [user setExternalServiceType:STKProfileInformationExternalServiceFacebook];
                    [user setAccountStoreID:[acct identifier]];
                    
                    [[self context] save:nil];
                    
                    block(user, nil, nil);
                } else {
                    if([valError isConnectionError]) {
                        block(nil, nil, valError);
                    } else {
                        // Fallback to registration
                        [self fetchFacebookDataForAccount:acct completion:^(STKProfileInformation *profInfo, NSError *dataErr) {
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
    STKConnection *c = [self connectionForEndpoint:STKUserEndpointValidateFacebook];
    [c addQueryValue:oauthToken forKey:@"ext_token"];
    [c setContext:[self context]];
    [c setEntityName:@"STKUser"];
    [c setExistingMatchMap:@{@"userID" : @"entity"}];
    [c getWithSession:[self userSession] completionBlock:block];
}

- (void)fetchFacebookDataForAccount:(ACAccount *)acct completion:(void (^)(STKProfileInformation *acct, NSError *err))block
{
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                        requestMethod:SLRequestMethodGET
                                                  URL:[NSURL URLWithString:@"https://graph.facebook.com/me"]
                                           parameters:nil];
    [self executeSocialRequest:req forAccount:acct completion:^(NSData *userData, NSError *userError) {
        if(!userError && userData) {
            NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:userData options:0 error:nil];
            
            STKProfileInformation *pi = [[STKProfileInformation alloc] init];
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
                        [pi setCoverPhotoURLString:source];
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

- (void)connectWithGoogle:(void (^)(STKUser *, STKProfileInformation *, NSError *))block
{
    [self fetchGoogleAccount:^(GTMOAuth2Authentication *auth, NSError *err) {
        if(!err) {
            [self validateWithGoogle:[auth accessToken] completion:^(STKUser *u, NSError *err) {
                if(!err) {
                    [self setCurrentUser:u];
                    [u setExternalServiceType:STKProfileInformationExternalServiceGoogle];
                    [[self context] save:nil];
                    
                    block(u, nil, nil);
                } else {
                    if([err isConnectionError]) {
                        block(nil, nil, err);
                    } else {
                        [self fetchGoogleDataForAuth:auth completion:^(STKProfileInformation *pi, NSError *err) {
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
{
    STKConnection *c = [self connectionForEndpoint:STKUserEndpointValidateGoogle];
    [c addQueryValue:token forKey:@"ext_token"];
    [c setContext:[self context]];
    [c setEntityName:@"STKUser"];
    [c setExistingMatchMap:@{@"userID" : @"entity"}];
    [c getWithSession:[self userSession] completionBlock:block];
}

- (void)fetchGoogleDataForAuth:(GTMOAuth2Authentication *)auth completion:(void (^)(STKProfileInformation *pi, NSError *err))block
{
    STKProfileInformation *pi = [[STKProfileInformation alloc] init];
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
            
            [self setCurrentUser:user];
            [[self context] save:nil];
            block(user, nil);
        } else {
            block(nil, err);
        }
    }];
}

- (void)validateWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(STKUser *user, NSError *err))block
{
    STKConnection *c = [self connectionForEndpoint:STKUserEndpointValidateEmail];
    [c addQueryValue:email forKey:@"login"];
    [c addQueryValue:password forKey:@"password"];
    
    [c setContext:[self context]];
    [c setEntityName:@"STKUser"];
    [c setExistingMatchMap:@{@"userID" : @"entity"}];
    
    [c getWithSession:[self userSession]
      completionBlock:block];
}

#pragma mark Uniform

- (void)registerAccount:(STKProfileInformation *)info completion:(void (^)(STKUser *user, NSError *err))block
{
    STKConnection *c = [self connectionForEndpoint:STKUserEndpointRegister];
    
    STKProfileInformation *transformedInfo = [info copy];
    
    [transformedInfo setGender:[self transformLookupValue:[info gender] forType:STKLookupTypeGender]];
    
    NSArray *missingKeys = nil;
    BOOL verified = [c addQueryObject:transformedInfo
                          missingKeys:&missingKeys
                           withKeyMap:@{@"firstName" : @"first_name",
                                        @"lastName" : @"last_name",
                                        @"email" : @"email_address",
                                        @"gender" : @"gender",
                                        @"zipCode" : @"zip_postal",
                                        @"birthday" : ^(id value) {
                                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                            [df setDateFormat:@"MM-dd-yyyy"];
                                            return @{@"date_of_birth" : [df stringFromDate:value]};
                                        }
    }];
    
    if(!verified) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, [self errorForCode:STKUserStoreErrorCodeMissingArguments
                                     data:missingKeys]);
        }];
        return;
    }
    
    if([transformedInfo externalService] && [transformedInfo externalID]) {
        [transformedInfo setExternalService:[self transformLookupValue:[info externalService] forType:STKLookupTypeSocial]];
        [c addQueryObject:transformedInfo missingKeys:nil withKeyMap:@{@"externalID" : @"external_id",
                                                                       @"externalService" : @"external_system"}];
    } else if([info password]) {
        [c addQueryObject:transformedInfo missingKeys:nil withKeyMap:@{@"password" : @"password"}];
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, [self errorForCode:STKUserStoreErrorCodeMissingArguments
                                     data:@[@"password", @"externalService", @"externalID"]]);
        }];
        return;
    }
    
    [c getWithSession:[self userSession] completionBlock:^(NSDictionary *obj, NSError *err) {
        if(!err) {
            void (^validationBlock)(STKUser *, NSError *) = ^(STKUser *u, NSError *valErr) {
                if(!valErr) {
                    if([info password]) {
                        STKSecurityStorePassword([u email], [info password]);
                    } else {
                        [u setExternalServiceType:[info externalService]];
                        [u setAccountStoreID:[info accountStoreID]];
                    }
                    [self setCurrentUser:u];
                
                    [[self context] save:nil];
                    block(u, nil);
                } else {
                    block(nil, valErr);
                }
            };
            
            // Now let us authenticate
            if([[info externalService] isEqualToString:STKProfileInformationExternalServiceGoogle]) {
                [self validateWithGoogle:[info token] completion:validationBlock];
            } else if([[info externalService] isEqualToString:STKProfileInformationExternalServiceFacebook]) {
                [self validateWithFacebook:[info token] completion:validationBlock];
            } else if([[info externalService] isEqualToString:STKProfileInformationExternalServiceTwitter]) {
                [self validateWithTwitterToken:[info token] secret:[info secret] completion:validationBlock];
            } else {
                [self validateWithEmail:[info email]
                               password:[info password]
                             completion:validationBlock];
            }
        } else {
            block(nil, err);
        }
    }];
}

- (void)attemptTransparentLoginWithUser:(STKUser *)u
{
    if(!u)
        return;
    
    void (^validationBlock)(STKUser *, NSError *) = ^(STKUser *u, NSError *valErr) {
        if(!valErr) {
            [[self context] save:nil];
        } else {
            [self setCurrentUser:nil];
    
            if([valErr isConnectionError]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:STKUserStoreTransparentLoginFailedNotification
                                                                    object:nil
                                                                  userInfo:@{STKUserStoreTransparentLoginFailedReasonKey : STKUserStoreTransparentLoginFailedConnectionValue,
                                                                             @"error" : valErr}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:STKUserStoreTransparentLoginFailedNotification
                                                                    object:nil
                                                                  userInfo:@{STKUserStoreTransparentLoginFailedReasonKey : STKUserStoreTransparentLoginFailedAuthenticationValue,
                                                                             @"error" : valErr}];
            }
        }
    };
    
    
    NSString *serviceType = [u externalServiceType];
    if([serviceType isEqualToString:STKProfileInformationExternalServiceFacebook]) {
        [self fetchFacebookAccountWithCompletion:^(ACAccount *acct, NSError *err) {
            if([[acct identifier] isEqualToString:[u accountStoreID]]) {
                [self validateWithFacebook:[[acct credential] oauthToken] completion:^(STKUser *u, NSError *err) {
                    validationBlock(u, err);
                }];
            } else {
                validationBlock(nil, [self errorForCode:STKUserStoreErrorCodeWrongAccount data:nil]);
            }
        }];
    } else if([serviceType isEqualToString:STKProfileInformationExternalServiceGoogle]) {
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
    } else if([serviceType isEqualToString:STKProfileInformationExternalServiceTwitter]) {
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

- (void)logout
{
    [self setCurrentUser:nil];
    // Cancel all connections!
}


- (NSString *)transformLookupValue:(NSString *)lookupValue forType:(NSString *)type
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:type];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"label like[cd] %@", lookupValue]];
    NSManagedObject *result = [[[self context] executeFetchRequest:fetch error:nil] firstObject];
    
    return [result valueForKey:@"identifier"];
}

@end
