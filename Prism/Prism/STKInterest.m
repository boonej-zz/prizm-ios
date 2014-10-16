//
//  STKInterest.m
//  Prizm
//
//  Created by Jonathan Boone on 10/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInterest.h"
#import "STKInterest.h"


@implementation STKInterest

@dynamic createDate;
@dynamic text;
@dynamic uniqueID;
@dynamic topLevel;
@dynamic subinterests;
@dynamic parent;
@dynamic isSubinterest;

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
             @"text" : @"text",
             @"subinterests" : [STKBind bindMapForKey:@"subinterests" matchMap:@{@"uniqueID" : @"_id"}],
             @"is_subinterest": @"isSubinterest"
             };
}

@end
