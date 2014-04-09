//
//  STKActivity.h
//  Prism
//
//  Created by Joe Conway on 4/8/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKUser;

extern NSString * const STKActivityItemContextPost;
extern NSString * const STKActivityItemContextUser;
extern NSString * const STKActivityItemContextComment;

extern NSString *const STKActivityItemActionCreate;
extern NSString *const STKActivityItemActionDelete; //remove

extern NSString *const STKActivityItemTypePost;
extern NSString *const STKActivityItemTypeFollow;
extern NSString *const STKActivityItemTypeUnfollow;
extern NSString *const STKActivityItemTypeLike;
extern NSString *const STKActivityItemTypeUnlike;
extern NSString *const STKActivityItemTypeComment;

@interface STKActivityItem : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSString * context;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic) BOOL hasBeenViewed;
@property (nonatomic, retain) NSString * referenceTimestamp;
@property (nonatomic, retain) NSString * targetID;
@property (nonatomic, retain) STKUser *creator;

- (NSString *)text;

@end
