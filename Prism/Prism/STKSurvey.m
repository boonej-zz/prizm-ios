//
//  STKSurvey.m
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKSurvey.h"
#import "STKGroup.h"
#import "STKQuestion.h"
#import "STKUser.h"


@implementation STKSurvey

@dynamic uniqueID;
@dynamic status;
@dynamic name;
@dynamic createDate;
@dynamic modifyDate;
@dynamic numberOfQuestions;
@dynamic targetAll;
@dynamic creator;
@dynamic groups;
@dynamic questions;
@dynamic completed;
@dynamic organization;
@dynamic points;
@dynamic rank;
@dynamic duration;

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
             @"status": @"status",
             @"name": @"name",
             @"create_date": [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"modify_date": [STKBind bindMapForKey:@"modifyDate" transform:STKBindTransformDateTimestamp],
             @"number_of_questions": @"numberOfQuestions",
             @"target_all": @"targetAll",
             @"creator": [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID" : @"_id"}],
             @"groups": [STKBind bindMapForKey:@"groups" matchMap:@{@"uniqueID" : @"_id"}],
             @"questions": [STKBind bindMapForKey:@"questions" matchMap:@{@"uniqueID" : @"_id"}],
             @"completed": [STKBind bindMapForKey:@"completed" matchMap:@{@"uniqueID" : @"_id"}],
             @"organization": [STKBind bindMapForKey:@"organization" matchMap:@{@"uniqueID" : @"_id"}],
             @"points": @"points",
             @"rank": @"rank",
             @"duration": @"duration"
    };
}


@end
