//
//  STKRequestItem.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKUser;

extern NSString * const STKRequestTypeTrust;
extern NSString * const STKRequestTypeAccolade;

extern NSString * const STKRequestStatusPending;
extern NSString * const STKRequestStatusAccepted;
extern NSString * const STKRequestStatusRejected;
extern NSString * const STKRequestStatusBlocked;

@interface STKRequestItem : NSManagedObject

@property (nonatomic) int32_t userID;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * profileImageURLString;
@property (nonatomic) NSString *type;
@property (nonatomic, retain) NSDate * dateReceived;
@property (nonatomic, retain) NSDate * dateConfirmed;
@property (nonatomic) BOOL accepted;
@property (nonatomic, retain) STKUser *user;

@end
