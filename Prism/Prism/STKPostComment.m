//
//  STKPostComment.m
//  Prism
//
//  Created by Joe Conway on 2/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPostComment.h"
#import "STKUser.h"
#import "STKUserStore.h"

@implementation STKPostComment
@dynamic uniqueID, text, date, likeCount, likes, post, creator, activities;

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id" : @"uniqueID",
             @"creator" : [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID" : @"_id"}],
             @"text" : @"text",
             @"create_date" : [STKBind bindMapForKey:@"date" transform:STKBindTransformDateTimestamp],
             // post
             @"likes_count" : @"likeCount",
             @"likes" : [STKBind bindMapForKey:@"likes" matchMap:@{@"uniqueID" : @"_id"}]
             };
}

- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self setUniqueID:jsonObject];
        return nil;
    }

    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

- (BOOL)isLikedByUser:(STKUser *)u
{
    return [[self likes] member:u] != nil;
}

- (NSDictionary *)mixpanelProperties
{
    return @{
             };
}

@end
