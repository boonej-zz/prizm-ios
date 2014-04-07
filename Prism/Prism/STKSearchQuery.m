//
//  STKSearchQuery.m
//  Prism
//
//  Created by Joe Conway on 4/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSearchQuery.h"

@implementation STKSearchQuery


+ (STKSearchQuery *)searchQueryForField:(NSString *)field value:(NSString *)value
{
    STKSearchQuery *c = [[STKSearchQuery alloc] init];
    
    [c setField:field];
    [c setValue:value];
    
    return c;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{@"search" :@{[self field] : [self value]}};
}



@end
