//
//  STKMessage.m
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKMessage.h"
#import "STKGroup.h"
#import "STKOrganization.h"
#import "STKUser.h"


@implementation STKMessage

@dynamic createDate;
@dynamic text;
@dynamic likesCount;
@dynamic creator;
@dynamic group;
@dynamic organization;
@dynamic likes;
@dynamic uniqueID;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self setUniqueID:jsonObject];
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id": @"uniqueID",
             @"text": @"text",
             @"likes_count": @"likesCount",
             @"organization": [STKBind bindMapForKey:@"organization" matchMap:@{@"uniqueID": @"_id"}],
             @"creator": [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID": @"_id"}],
             @"group": [STKBind bindMapForKey:@"group" matchMap:@{@"uniqueID": @"_id"}],
             @"likes": [STKBind bindMapForKey:@"likes" matchMap:@{@"uniqueID": @"_id"}],
             @"create_date": [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp]
             };
}

@end
