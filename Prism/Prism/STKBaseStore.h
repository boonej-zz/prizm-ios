//
//  STKBaseStore.h
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@class STKUser, STKConnection;

extern NSString * const STKLookupTypeGender;
extern NSString * const STKLookupTypeSocial;

@interface STKBaseStore : NSObject

+ (STKBaseStore *)store;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSURLSession *session;

- (NSString *)transformLookupValue:(NSString *)lookupValue forType:(NSString *)type;
- (STKConnection *)connectionForEndpoint:(NSString *)endpoint;

- (NSArray *)executeFetchRequest:(NSFetchRequest *)req;

@end
