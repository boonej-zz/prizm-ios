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

- (NSDictionary *)dictionaryRepresentation
{
    NSDictionary *base = [super dictionaryRepresentation];
    
    return @{@"resolve" : @{[self field] : base}};
}

@end
