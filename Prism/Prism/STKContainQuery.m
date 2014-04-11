//
//  STKContainQuery.m
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKContainQuery.h"

@implementation STKContainQuery

+ (STKContainQuery *)containQueryForField:(NSString *)field
                                keyValues:(NSDictionary *)dict
{
    STKContainQuery *c = [[STKContainQuery alloc] init];
    
    [c setField:field];
    [c setKeyValues:dict];
    
    return c;
}


+ (STKContainQuery *)containQueryForField:(NSString *)field
                                      key:(NSString *)key
                                    value:(NSString *)value
{
    STKContainQuery *c = [[STKContainQuery alloc] init];

    [c setField:field];
    [c setValue:value];
    [c setKey:key];
    
    return c;
}

- (NSDictionary *)dictionaryRepresentation
{
    if([self keyValues]) {
        return @{@"contains" : @{[self field] : [self keyValues]}};
    }
    
    return @{@"contains" :@{[self field] : @{[self key] : [self value]}}};
}

@end
