//
//  STKOrgStatus.m
//  Prizm
//
//  Created by Jonathan Boone on 4/14/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKOrgStatus.h"
#import "STKGroup.h"
#import "STKOrganization.h"
#import "STKUser.h"


@implementation STKOrgStatus

@dynamic status;
@dynamic createDate;
@dynamic organization;
@dynamic groups;
@dynamic member;


- (NSError *) readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"create_date": [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"organization": [STKBind bindMapForKey:@"organization" matchMap:@{@"uniqueID": @"_id"}],
             @"groups": [STKBind bindMapForKey:@"groups" matchMap:@{@"uniqueID": @"_id"}],
             @"status": @"status"
             
             };
}

@end
