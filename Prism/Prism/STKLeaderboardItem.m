//
//  STKLeaderboardItem.m
//  Prizm
//
//  Created by Jonathan Boone on 8/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKLeaderboardItem.h"
#import "STKOrganization.h"
#import "STKUser.h"


@implementation STKLeaderboardItem

@dynamic userID;
@dynamic points;
@dynamic user;
@dynamic organization;
@dynamic surveys;


- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self bindFromDictionary:@{@"_id" : jsonObject} keyMap:@{@"_id" : @"userID"}];
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id": @"userID",
             @"points": @"points",
             @"user": [STKBind bindMapForKey:@"user" matchMap:@{@"uniqueID" : @"_id"}],
             @"organization": [STKBind bindMapForKey:@"organization" matchMap:@{@"uniqueID" : @"_id"}],
             @"surveys": @"surveys"
             };
}

@end
