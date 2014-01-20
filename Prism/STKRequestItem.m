//
//  STKRequestItem.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKRequestItem.h"
#import "STKUser.h"

NSString * const STKRequestTypeTrust = @"1";
NSString * const STKRequestTypeAccolade = @"2";

NSString * const STKRequestStatusPending = @"1";
NSString * const STKRequestStatusAccepted = @"2";
NSString * const STKRequestStatusRejected = @"3";
NSString * const STKRequestStatusBlocked = @"4";


@implementation STKRequestItem

@dynamic userID;
@dynamic userName;
@dynamic profileImageURLString;
@dynamic type;
@dynamic dateReceived;
@dynamic dateConfirmed;
@dynamic accepted;
@dynamic user;

@end
