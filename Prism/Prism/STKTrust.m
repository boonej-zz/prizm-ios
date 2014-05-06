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

- (NSString *)description
{
    return [NSString stringWithFormat:@"STKTrust (%@) from %@ to %@ Status: %@ ModifiedDate: %@",
            [self uniqueID], [[self creator] name], [[self recepient] name], [self status], [self dateModified]];
}


+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id" : @"uniqueID",
             @"status" : @"status",
             @"type" : @"type",
             @"to" : [STKBind bindMapForKey:@"recepient" matchMap:@{@"uniqueID" : @"_id"}],
             @"from" : [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID" : @"_id"}],
             @"create_date" : [STKBind bindMapForKey:@"dateCreated" transform:STKBindTransformDateTimestamp],
             @"modify_date" : [STKBind bindMapForKey:@"dateModified" transform:STKBindTransformDateTimestamp],
             @"to_likes_count" : @"recepientLikesCount",
             @"to_comments_count" : @"recepientCommentsCount",
             @"to_posts_count" : @"recepientPostsCount",
             @"from_likes_count" : @"creatorLikesCount",
             @"from_comments_count" : @"creatorCommentsCount",
             @"from_posts_count" : @"creatorPostsCount"
             };
}

- (NSError *)readFromJSONObject:(id)jsonObject
{

    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

- (STKUser *)otherUser
{
    if([[[self creator] uniqueID] isEqualToString:[[[STKUserStore store] currentUser] uniqueID]]) {
        return [self recepient];
    }
    
    return [self creator];
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
