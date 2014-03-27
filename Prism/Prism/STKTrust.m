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


@implementation STKTrust
@dynamic uniqueID, status, dateCreated, owningUser, otherUser;

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
                                                 @"user_id" : @{@"key" : @"otherUser", @"match" : @{@"uniqueID" : @"_id"}},
                                                 @"create_date" : ^(NSString *inValue) {
                                                     [self setDateCreated:[df dateFromString:inValue]];
                                                 },
                                                 
    }];
    
//    [self setIsOwner:[[jsonObject objectForKey:@"is_owner"] boolValue]];
    
    return nil;
}

- (BOOL)currentUserIsOwner
{
    return [[[STKUserStore store] currentUser] isEqual:[self owningUser]];
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
