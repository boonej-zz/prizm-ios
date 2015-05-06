//
//  STKOrganization.m
//  Prizm
//
//  Created by Jonathan Boone on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKOrganization.h"
#import "STKTheme.h"
#import "STKUser.h"


@implementation STKOrganization

@dynamic uniqueID;
@dynamic code;
@dynamic name;
@dynamic createDate;
@dynamic modifyDate;
@dynamic welcomeMessage;
@dynamic welcomeImageURL;
@dynamic theme;
@dynamic members;
@dynamic logoURL;
@dynamic owner;
@dynamic messages;
@dynamic mutes;

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
             @"_id" : @"uniqueID",
             @"code" : @"code",
             @"name" : @"name",
             @"welcome_message": @"welcomeMessage",
             @"welcome_image_url": @"welcomeImageURL",
             @"logo_url":@"logoURL",
             @"theme": [STKBind bindMapForKey:@"theme" matchMap:@{@"uniqueID": @"_id"}],
             @"create_date":[STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"modify_date":[STKBind bindMapForKey:@"modifyDate" transform:STKBindTransformDateTimestamp],
             @"owner": [STKBind bindMapForKey:@"owner" matchMap:@{@"uniqueID": @"_id"}],
             @"mutes": [STKBind bindMapForKey:@"mutes" matchMap:@{@"uniqueID": @"_id"}]};
}

@end
