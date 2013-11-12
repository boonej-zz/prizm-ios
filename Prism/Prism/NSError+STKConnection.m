//
//  NSError+STKConnection.m
//  Rheem EcoNet
//
//  Created by Joe Conway on 6/3/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.

#import "NSError+STKConnection.h"

NSString * const STKConnectionServiceErrorDomain = @"STKConnectionServiceErrorDomain";
NSString * const STKConnectionStatusCodeErrorDomain = @"STKConnectionStatusCodeErrorDomain";

@implementation NSError (STKConnection)

- (BOOL)isConnectionError
{
    return [[self domain] isEqualToString:NSURLErrorDomain];
}

- (BOOL)isServiceError
{
    return [[self domain] isEqualToString:STKConnectionServiceErrorDomain];
}

- (BOOL)isStatusCodeError
{
    return [[self domain] isEqualToString:STKConnectionStatusCodeErrorDomain];
}

@end
