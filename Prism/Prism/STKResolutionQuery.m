//
//  STKResolutionQuery.m
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKResolutionQuery.h"

@implementation STKResolutionQuery

+ (STKResolutionQuery *)resolutionQueryForField:(NSString *)field
{
    STKResolutionQuery *a = [[STKResolutionQuery alloc] init];

    [a setField:field];
    
    return a;
}

- (id)init
{
    self = [super init];
    if(self) {
        [self setFormat:STKQueryObjectFormatShort];
    }
    return self;
}


- (NSDictionary *)dictionaryRepresentation
{
    NSDictionary *base = [super dictionaryRepresentation];
    
    return @{@"resolve" : @{[self field] : base}};
}

@end
