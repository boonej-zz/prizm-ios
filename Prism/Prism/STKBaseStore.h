//
//  STKBaseStore.h
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@class STKUser, STKConnection, STKAuthorizationToken;

extern NSString * const STKSessionEndedNotification;
extern NSString * const STKSessionEndedReasonKey;
extern NSString * const STKSessionEndedConnectionValue;
extern NSString * const STKSessionEndedAuthenticationValue;
extern NSString * const STKSessionEndedLogoutValue;

extern NSString * const STKAuthenticationErrorDomain;

typedef enum {
    STKLookupTypeCitizenship,
    STKLookupTypeCountry,
    STKLookupTypeRace,
    STKLookupTypeRegion,
    STKLookupTypeReligion
} STKLookupType;

@interface STKBaseStore : NSObject

+ (STKBaseStore *)store;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) STKAuthorizationToken *authorizationToken;

- (NSString *)labelForCode:(NSString *)code type:(STKLookupType)type;
- (NSNumber *)codeForLookupValue:(NSString *)lookupValue type:(STKLookupType)type;

- (STKConnection *)connectionForEndpoint:(NSString *)endpoint;

- (NSArray *)executeFetchRequest:(NSFetchRequest *)req;

- (void)fetchAccessToken:(void (^)(STKAuthorizationToken *token, NSError *err))block;

- (void)executeAuthorizedRequest:(void (^)(BOOL granted))request;

@end
