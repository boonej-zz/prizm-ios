//
//  STKPost.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"
#import "STKUser.h"

@import CoreLocation;

extern NSString * const STKPostTypeAspiration;
extern NSString * const STKPostTypeInspiration;
extern NSString * const STKPostTypeExperience;
extern NSString * const STKPostTypeAchievement;
extern NSString * const STKPostTypePassion;
extern NSString * const STKPostTypeAccolade;
extern NSString * const STKPostTypePersonal;

extern NSString * const STKPostVisibilityPublic;
extern NSString * const STKPostVisibilityTrust;
extern NSString * const STKPostVisibilityPrivate;

extern NSString * const STKPostLocationLatitudeKey;
extern NSString * const STKPostLocationLongitudeKey;
extern NSString * const STKPostLocationNameKey;
extern NSString * const STKPostURLKey;
extern NSString * const STKPostTextKey;
extern NSString * const STKPostTypeKey;
extern NSString * const STKPostVisibilityKey;
extern NSString * const STKPostHashTagsKey;

extern NSString * const STKPostStatusDeleted;

@interface STKPost : NSObject <STKJSONObject>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSString *locationName;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) STKUser *creator;

@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic, strong) NSString *referenceTimestamp;

@property (nonatomic, retain) NSString *imageURLString;

@property (nonatomic, strong) NSString *status;

@property (nonatomic) NSString *type;
@property (nonatomic) int commentCount;
@property (nonatomic) int likeCount;
@property (nonatomic) BOOL postLikedByCurrentUser;

@property (nonatomic, strong) NSArray *hashTags;
@property (nonatomic, strong) NSArray *comments;

- (UIImage *)typeImage;

+ (UIImage *)imageForType:(NSString *)t;

@end
