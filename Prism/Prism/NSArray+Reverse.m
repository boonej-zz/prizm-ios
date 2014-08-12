//
//  NSArray+Reverse.m
//  Prizm
//
//  Created by Jonathan Boone on 8/12/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray
{
    NSMutableArray *ma = [NSMutableArray arrayWithCapacity:self.count];
    NSEnumerator *en = [self reverseObjectEnumerator];
    for (id obj in en) {
        [ma addObject:obj];
    }
    return [ma copy];
}

@end
