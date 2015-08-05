//
//  STKQuestionOption.m
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKQuestionOption.h"
#import "STKQuestion.h"


@implementation STKQuestionOption

@dynamic uniqueID;
@dynamic text;
@dynamic order;
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
             @"question": @"text",
             @"order": @"order"
    };
}

@end
