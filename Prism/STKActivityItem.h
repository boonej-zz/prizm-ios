//
//  STKActivity.h
//  Prism
//
//  Created by Joe Conway on 4/8/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKUser, STKPost, STKPostComment, STKInsightTarget, STKInsight, STKMessage;

extern NSString *const STKActivityItemTypePost;
extern NSString *const STKActivityItemTypeFollow;
extern NSString *const STKActivityItemTypeUnfollow;
extern NSString *const STKActivityItemTypeLike;
extern NSString *const STKActivityItemTypeUnlike;
extern NSString *const STKActivityItemTypeComment;
extern NSString *const STKActivityItemTypeTrustAccepted;
extern NSString * const STKActivityItemTypeTag;
extern NSString * const STKActivityItemTypeAccolade;

@interface STKActivityItem : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSDate * dateCreated;

@property (nonatomic) BOOL hasBeenViewed;

@property (nonatomic, retain) STKPost *post;
@property (nonatomic, strong) STKPostComment *comment;
@property (nonatomic, strong) STKInsightTarget *insightTarget;
@property (nonatomic, strong) STKInsight *insight;
@property (nonatomic, retain) STKUser *creator;
@property (nonatomic, strong) STKUser *notifiedUser;
@property (nonatomic, retain) STKMessage *message;

- (NSString *)text;

@end
