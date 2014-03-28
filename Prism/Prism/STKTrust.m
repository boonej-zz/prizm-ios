//
//  STKTrust.m
//  Prism
//
//  Created by Joe Conway on 3/19/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTrust.h"
#import "STKUser.h"
#import "STKUserStore.h"

NSString * const STKRequestStatusPending = @"pending";
NSString * const STKRequestStatusAccepted = @"accepted";
NSString * const STKRequestStatusRejected = @"rejected";
NSString * const STKRequestStatusCancelled = @"cancelled";

@interface STKTrust ()

@end

@implementation STKTrust
@dynamic uniqueID, status, dateCreated, owningUser, otherUser, owningUserRequestedTrust;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }

    [self bindFromDictionary:jsonObject keyMap:@{
                                                 @"_id" : @"uniqueID",
                                                 @"status" : @"status",
                                                 @"is_owner" : @"owningUserRequestedTrust",
                                                 @"user_id" : @{STKJSONBindFieldKey : @"otherUser", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"create_date" : ^(NSString *inValue) {
                                                     [self setDateCreated:[df dateFromString:inValue]];
                                                 },
                                                 
    }];
    
    return nil;
}

- (STKUser *)requestor
{
    if([self owningUserRequestedTrust])
        return [self owningUser];
    
    return [self otherUser];
}

- (BOOL)isPending
{
    return [[self status] isEqualToString:STKRequestStatusPending];
}
- (BOOL)isAccepted
{
    return [[self status] isEqualToString:STKRequestStatusAccepted];    
}
- (BOOL)isRejected
{
    return [[self status] isEqualToString:STKRequestStatusRejected];
}
- (BOOL)isCancelled
{
    return [[self status] isEqualToString:STKRequestStatusCancelled];
}

@end
