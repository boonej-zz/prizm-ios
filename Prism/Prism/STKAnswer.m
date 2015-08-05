//
//  STKAnswer.m
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKAnswer.h"
#import "STKQuestion.h"
#import "STKUser.h"


@implementation STKAnswer

@dynamic uniqueID;
@dynamic value;
@dynamic createDate;
@dynamic user;
@dynamic question;

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
             @"value": @"value",
             @"create_date": [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"user": [STKBind bindMapForKey:@"user" matchMap:@{@"uniqueID" : @"_id"}],
             @"question": [STKBind bindMapForKey:@"question" matchMap:@{@"uniqueID" : @"_id"}]
             };
}

@end
