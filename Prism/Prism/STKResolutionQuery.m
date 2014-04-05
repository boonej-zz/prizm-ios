//
//  STKResolutionQuery.m
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKResolutionQuery.h"

@implementation STKResolutionQuery

+ (STKResolutionQuery *)resolutionQueryForEntityName:(NSString *)entityName
                                       serverTypeKey:(NSString *)serverTypeKey
                                               field:(NSString *)field
{
    STKResolutionQuery *a = [[STKResolutionQuery alloc] init];

    [a setEntityName:entityName];
    [a setServerTypeKey:serverTypeKey];
    [a setField:field];
    
    return a;
}

- (NSString *)parentKey
{
    return @"resolve";
}

- (NSDictionary *)dictionaryRepresentation
{
    NSDictionary *base = [super dictionaryRepresentation];
    
    return @{[self field] : base};
}

@end
