//
//  STKTheme.m
//  Prizm
//
//  Created by Jonathan Boone on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTheme.h"


@implementation STKTheme

@dynamic uniqueID;
@dynamic backgroundURL;
@dynamic textColor;
@dynamic dominantColor;
@dynamic createDate;
@dynamic modifyDate;
@dynamic organization;

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
             @"background_url" : @"backgroundURL",
             @"text_color" : @"textColor",
             @"dominant_color": @"dominantColor",
             @"create_date":[STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"modify_date":[STKBind bindMapForKey:@"modifyDate" transform:STKBindTransformDateTimestamp]
             };
}

@end
