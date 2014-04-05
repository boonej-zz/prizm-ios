//
//  STKContainQuery.m
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKContainQuery.h"

@implementation STKContainQuery

+ (STKContainQuery *)containQueryForField:(NSString *)field value:(NSString *)value
{
    STKContainQuery *c = [[STKContainQuery alloc] init];

    [c setField:field];
    [c setValue:value];
    
    return c;
}

- (NSString *)parentKey
{
    return @"contains";
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{[self field] : [self value]};
}

@end
