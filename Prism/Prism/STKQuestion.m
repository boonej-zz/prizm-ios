//
//  STKQuestion.m
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKQuestion.h"


@implementation STKQuestion

@dynamic uniqueID;
@dynamic text;
@dynamic scale;
@dynamic createDate;
@dynamic modifyDate;
@dynamic order;
@dynamic answers;
@dynamic options;
@dynamic survey;
@dynamic type;

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
             @"scale": @"scale",
             @"create_date": [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"modify_date": [STKBind bindMapForKey:@"modifyDate" transform:STKBindTransformDateTimestamp],
             @"order": @"order",
             @"text": @"text",
             @"type": @"type",
             @"answers": [STKBind bindMapForKey:@"answers" matchMap:@{@"uniqueID" : @"_id"}],
             @"values": [STKBind bindMapForKey:@"options" matchMap:@{@"uniqueID" : @"_id"}]
             };
}

@end
