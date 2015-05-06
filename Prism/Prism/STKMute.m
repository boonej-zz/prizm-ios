//
//  STKMute.m
//  Prizm
//
//  Created by Jonathan Boone on 5/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKMute.h"
#import "STKGroup.h"
#import "STKOrganization.h"
#import "STKUser.h"


@implementation STKMute

@dynamic uniqueID;
@dynamic createDate;
@dynamic revokeDate;
@dynamic user;
@dynamic organization;
@dynamic group;

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
             @"create_date": [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"revoke_date": [STKBind bindMapForKey:@"revokeDate" transform:STKBindTransformDateTimestamp],
             @"user": [STKBind bindMapForKey:@"user" matchMap:@{@"uniqueID": @"_id"}],
             @"organization": [STKBind bindMapForKey:@"organization" matchMap:@{@"uniqueID": @"_id"}],
             @"group": [STKBind bindMapForKey:@"group" matchMap:@{@"uniqueID": @"_id"}]
             };
}

@end
