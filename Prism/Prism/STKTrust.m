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
@dynamic uniqueID, status, dateCreated, dateModified, creator, creatorCommentsCount, creatorLikesCount, creatorPostsCount,
recepient, recepientCommentsCount, recepientLikesCount, recepientPostsCount, type;

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
                                                 @"type" : @"type",
                                                 @"to" : @{STKJSONBindFieldKey : @"recepient", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"from" : @{STKJSONBindFieldKey : @"creator", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"create_date" : ^(NSString *inValue) {
                                                     [self setDateCreated:[df dateFromString:inValue]];
                                                 },
                                                 @"modify_date" : ^(NSString *inValue) {
                                                     [self setDateModified:[df dateFromString:inValue]];
                                                 },
                                                 @"to_likes_count" : @"recepientLikesCount",
                                                 @"to_comments_count" : @"recepientCommentsCount",
                                                 @"to_posts_count" : @"recepientPostsCount",
                                                 @"from_likes_count" : @"creatorLikesCount",
                                                 @"from_comments_count" : @"creatorCommentsCount",
                                                 @"from_posts_count" : @"creatorPostsCount"
    }];
    
    return nil;
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
