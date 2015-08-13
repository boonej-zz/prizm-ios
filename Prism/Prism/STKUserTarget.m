//
//  STKUserTarget.m
//  Prizm
//
//  Created by Jonathan Boone on 8/13/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKUserTarget.h"
#import "STKSurvey.h"
#import "STKUser.h"


@implementation STKUserTarget

@dynamic uniqueID;
@dynamic createDate;
@dynamic user;
@dynamic survey;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self bindFromDictionary:@{@"_id" : jsonObject} keyMap:@{@"_id" : @"uniqueID"}];
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
             @"user": [STKBind bindMapForKey:@"user" matchMap:@{@"uniqueID" : @"_id"}]
        
             };
}

@end
