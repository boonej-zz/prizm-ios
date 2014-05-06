//
//  STKQueryObject.m
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKQueryObject.h"

NSString * const STKQueryObjectFormatBasic = @"basic";
NSString * const STKQueryObjectFormatShort = @"short";


@implementation STKQueryObject

- (void)addSubquery:(STKQueryObject *)obj
{
    if(![self subqueries])
        [self setSubqueries:[[NSMutableArray alloc] init]];
    
    [[self subqueries] addObject:obj];
}

- (NSString *)parentKey
{
    return nil;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    
    if([self fields])
        [d setObject:[[self fields] componentsJoinedByString:@" "] forKey:@"fields"];
    
    if([self filters])
        [d addEntriesFromDictionary:[self filters]];
    
    if([self sortKey]) {
        [d setObject:[self sortKey] forKey:@"sort_by"];
        [d setObject:@([self sortOrder]) forKey:@"sort"];
    }
    
    if([self pageKey] && [self pageValue]) {
        [d setObject:[self pageValue] forKey:@"page"];
        [d setObject:[self pageKey] forKey:@"page_by"];
        if([self pageDirection] != STKQueryObjectPageReload)
            [d setObject:@([self pageDirection]) forKey:@"page_direction"];
    }
    
    if([self format]) {
        [d setObject:[self format] forKey:@"format"];
    }
    
    if([self limit] > 0)
        [d setObject:@([self limit]) forKey:@"limit"];
    
    for(STKQueryObject *obj in [self subqueries]) {
        NSDictionary *dict = [obj dictionaryRepresentation];
        for(NSString *key in dict) {
            if([d objectForKey:key]) {
                NSMutableDictionary *m = [[d objectForKey:key] mutableCopy];
                [m addEntriesFromDictionary:[dict objectForKey:key]];
                [d setObject:m forKey:key];
            } else {
                [d setObject:[dict objectForKey:key] forKey:key];
            }
        }
    }
    
    return [d copy];
}

@end
