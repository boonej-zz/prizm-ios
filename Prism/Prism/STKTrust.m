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

- (NSError *)readFromJSONObject:(id)jsonObject
{
    NSDictionary *t = (NSDictionary *)jsonObject;
    [self setTrustID:[t objectForKey:@"_id"]];
    [self setStatus:[t objectForKey:@"status"]];
    
    if([[t objectForKey:@"user_id"] isKindOfClass:[NSDictionary class]]) {
        STKUser *u = [[STKUser alloc] init];
        [u readFromJSONObject:[t objectForKey:@"user_id"]];
        [self setOtherUser:u];
    } else {
        // This is a temporary hack, remove once fixed.
        STKUser *u = [[STKUser alloc] init];
        [u setUserID:[t objectForKey:@"user_id"]];
        [self setOtherUser:u];
    }
    
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    [self setDateCreated:[df dateFromString:[t objectForKey:@"create_date"]]];
    
    [self setIsOwner:[[jsonObject objectForKey:@"is_owner"] boolValue]];
    
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
