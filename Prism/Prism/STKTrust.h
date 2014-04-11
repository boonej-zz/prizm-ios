//
//  STKTrust.h
//  Prism
//
//  Created by Joe Conway on 3/19/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"

@class STKUser;

extern NSString * const STKRequestStatusPending;
extern NSString * const STKRequestStatusAccepted;
extern NSString * const STKRequestStatusRejected;
extern NSString * const STKRequestStatusCancelled;


@interface STKTrust : NSManagedObject <STKJSONObject>

@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSDate *dateModified;
@property (nonatomic, strong) NSString *type;

@property (nonatomic) int creatorPostsCount;
@property (nonatomic) int creatorCommentsCount;
@property (nonatomic) int creatorLikesCount;
@property (nonatomic) int recepientPostsCount;
@property (nonatomic) int recepientCommentsCount;
@property (nonatomic) int recepientLikesCount;

@property (nonatomic, strong) STKUser *recepient;
@property (nonatomic, strong) STKUser *creator;

- (BOOL)isPending;
- (BOOL)isAccepted;
- (BOOL)isRejected;
- (BOOL)isCancelled;

@end
