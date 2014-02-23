//
//  STKBaseStore.m
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKBaseStore.h"
#import "STKConnection.h"
#import "STKAuthorizationToken.h"

@import Security;

NSString * const STKUserBaseURLString = @"https://ec2-54-200-41-62.us-west-2.compute.amazonaws.com";

NSString * const STKPrismClientSecret = @"f27198fb-689d-4965-acb0-0e9c5f61ddec";
NSString * const STKPrismClientID = @"67e1fe4f-db1b-4d5c-bdc7-56270b0822e2";
NSString * const STKPrismRedirectURI = @"https://ec2-54-200-41-62.us-west-2.compute.amazonaws.com/callback";

NSString * const STKBaseStoreEndpointAuthorization = @"/oauth2/authorize";
NSString * const STKBaseStoreEndpointToken = @"/oauth2/token";

NSString * const STKSessionEndedNotification = @"STKUserStoreCurrentUserSessionEndedNotification";
NSString * const STKSessionEndedReasonKey = @"STKUserStoreCurrentUserSessionEndedReasonKey";
NSString * const STKSessionEndedConnectionValue = @"STKUserStoreCurrentUserSessionEndedConnectionValue";
NSString * const STKSessionEndedAuthenticationValue = @"STKUserStoreCurrentUserSessionEndedAuthenticationValue";
NSString * const STKSessionEndedLogoutValue = @"STKUserStoreCurrentUserSessionEndedLogoutValue";

NSString * const STKAuthenticationErrorDomain = @"STKAuthenticationErrorDomain";

@interface STKBaseStore () <NSURLSessionDelegate>

@property (nonatomic, strong) NSManagedObjectContext *lookupContext;
@property (nonatomic, strong) NSMutableArray *authorizedRequestQueue;

@end

@implementation STKBaseStore

+ (STKBaseStore *)store
{
    static STKBaseStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKBaseStore alloc] init];
    });
    
    return store;
}

+ (NSURL *)baseURL
{
    return [NSURL URLWithString:STKUserBaseURLString];
}

- (id)init
{
    self = [super init];
    if(self) {
        _authorizedRequestQueue = [[NSMutableArray alloc] init];
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
        
        
        NSString *lookupPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"lookup.sqlite"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:lookupPath]) {
            [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"lookup" ofType:@"sqlite"]
                                                    toPath:lookupPath
                                                     error:nil];
        }
        
        mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Lookup"
                                                                                          withExtension:@"momd"]];
        psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        error = nil;
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[NSURL fileURLWithPath:lookupPath]
                                    options:@{NSSQLitePragmasOption : @{@"journal_mode" : @"OFF"}}
                                      error:&error]) {
            [NSException raise:@"Open failed" format:@"Reason %@", [error localizedDescription]];
        }
        
        _lookupContext = [[NSManagedObjectContext alloc] init];
        [[self lookupContext] setPersistentStoreCoordinator:psc];
        [[self lookupContext] setUndoManager:nil];

        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
        
        
//

    }
    return self;
}

- (void)executeAuthorizedRequest:(void (^)(BOOL granted))request
{
    if([self authorizationToken] && [[[self authorizationToken] expiration] timeIntervalSinceNow] > 0) {
        request(YES);
    } else {
        NSLog(@"Auth token has expired, queuing and requesting");
        [[self authorizedRequestQueue] addObject:request];
        if([[self authorizationToken] refreshToken]) {
            [self refreshAccessToken:^(STKAuthorizationToken *token, NSError *err) {
                for(void (^req)(BOOL) in [self authorizedRequestQueue]) {
                    req(err == nil);
                }
                [[self authorizedRequestQueue] removeAllObjects];
            }];
        } else {
            [self fetchAccessToken:^(STKAuthorizationToken *token, NSError *err) {
                for(void (^req)(BOOL) in [self authorizedRequestQueue]) {
                    req(err == nil);
                }
                [[self authorizedRequestQueue] removeAllObjects];
            }];
        }
    }
}



- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } 
}

- (NSString *)authenticationString
{
    NSString *authHeaderValue = [NSString stringWithFormat:@"%@:%@", STKPrismClientID, STKPrismClientSecret];
    NSString *base64EncodedValue = [[authHeaderValue dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"Basic %@", base64EncodedValue];
}

- (void)fetchAuthorizationCodeCompletion:(void (^)(NSString *code, NSError *err))block
{
    STKConnection *c = [self connectionForEndpoint:STKBaseStoreEndpointAuthorization];
    
    [c addQueryValue:@"code" forKey:@"response_type"];
    [c addQueryValue:STKPrismClientID forKey:@"client_id"];
    [c addQueryValue:STKPrismRedirectURI forKey:@"redirect_uri"];
    
    [c setAuthorizationString:[self authenticationString]];

    [c getWithSession:[self session] completionBlock:^(NSDictionary *obj, NSError *err) {
        NSString *authCode = [obj objectForKey:@"authorization_code"];
        block(authCode, err);
    }];
}

- (void)fetchAccessToken:(void (^)(STKAuthorizationToken *token, NSError *err))block
{
    [self fetchAuthorizationCodeCompletion:^(NSString *code, NSError *err) {
        if(!err) {
            STKConnection *c = [self connectionForEndpoint:STKBaseStoreEndpointToken];
            [c addQueryValue:code forKey:@"code"];
            [c addQueryValue:@"authorization_code" forKey:@"grant_type"];
            [c addQueryValue:STKPrismRedirectURI forKey:@"redirect_uri"];
            [c setAuthorizationString:[self authenticationString]];
            
            [c setModelGraph:@[@"STKAuthorizationToken"]];
            
            [c postWithSession:[self session] completionBlock:^(STKAuthorizationToken *obj, NSError *err) {
                [self setAuthorizationToken:obj];
                block(obj, err);
            }];
        } else {
            block(nil, err);
        }
    }];
}

- (void)refreshAccessToken:(void (^)(STKAuthorizationToken *token, NSError *err))block
{
    STKConnection *c = [self connectionForEndpoint:STKBaseStoreEndpointToken];
    [c addQueryValue:[[self authorizationToken] refreshToken] forKey:@"code"];
    [c addQueryValue:@"refresh_token" forKey:@"grant_type"];
    [c addQueryValue:STKPrismRedirectURI forKey:@"redirect_uri"];
    [c setAuthorizationString:[self authenticationString]];
    
    [c setModelGraph:@[@"STKAuthorizationToken"]];
    
    [c postWithSession:[self session] completionBlock:^(STKAuthorizationToken *obj, NSError *err) {
        [self setAuthorizationToken:obj];
        block(obj, err);
    }];
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)req
{
    return [[self context] executeFetchRequest:req error:nil];
}

- (STKConnection *)connectionForEndpoint:(NSString *)endpoint
{
    STKConnection *c = [[STKConnection alloc] initWithBaseURL:[[self class] baseURL]
                                                     endpoint:endpoint];
    
    if([self authorizationToken]) {
        [c setAuthorizationString:[NSString stringWithFormat:@"Bearer %@", [[self authorizationToken] accessToken]]];
    }
    
    return c;
}



@end
