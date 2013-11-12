//
//  NSError+STKConnection.h
//  Rheem EcoNet
//
//  Created by Joe Conway on 6/3/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.

#import <Foundation/Foundation.h>

extern NSString * const STKConnectionServiceErrorDomain;
extern NSString * const STKConnectionStatusCodeErrorDomain;

@interface NSError (STKConnection)

- (BOOL)isConnectionError;
- (BOOL)isServiceError;
- (BOOL)isStatusCodeError;

@end
