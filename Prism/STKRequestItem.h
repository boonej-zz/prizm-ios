//
//  STKRequestItem.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKProfile;

extern NSString * const STKRequestTypeTrust;
extern NSString * const STKRequestTypeAccolade;

extern NSString * const STKRequestStatusPending;
extern NSString * const STKRequestStatusAccepted;
extern NSString * const STKRequestStatusRejected;
extern NSString * const STKRequestStatusBlocked;

@interface STKRequestItem : NSObject <STKJSONObject>

@property (nonatomic, strong) STKProfile *requestingProfile;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *status;

@end
