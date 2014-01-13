//
//  NSCharacterSet+STKURL.m
//  Prism
//
//  Created by Joe Conway on 1/8/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "NSCharacterSet+STKURL.h"

@implementation NSCharacterSet (STKURL)
+ (NSCharacterSet *)URLArgumentAllowedCharacterSet
{
    static NSCharacterSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *s = [[NSMutableCharacterSet alloc] init];
        [s addCharactersInString:@"!$'()*+,-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"];
        set = [s copy];
    });
    return set;
}
@end
