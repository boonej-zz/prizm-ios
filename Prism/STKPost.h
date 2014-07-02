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

@class STKPost;

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

extern NSString * const STKPostVisibilityKey;
extern NSString * const STKPostAccoladeReceiverKey;
extern NSString * const STKPostLocationLatitudeKey;
extern NSString * const STKPostLocationLongitudeKey;
extern NSString * const STKPostLocationNameKey;
extern NSString * const STKPostURLKey;
extern NSString * const STKPostTextKey;
extern NSString * const STKPostTypeKey;
extern NSString * const STKPostVisibilityKey;
extern NSString * const STKPostHashTagsKey;
extern NSString * const STKPostOriginIDKey;
extern NSString * const STKPostDateCreatedKey;

extern NSString * const STKPostHashTagURLScheme;
extern NSString * const STKPostUserURLScheme;

extern NSString * const STKPostStatusDeleted;
extern NSString * const STKPostExternalProvider;

@interface STKPost : NSManagedObject <STKJSONObject>

+ (UIImage *)imageForType:(NSString *)t;
+ (UIImage *)disabledImageForType:(NSString *)t;

@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic) NSString *type;
@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *visibility;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, getter = isRepost) BOOL repost;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *creatorType;
@property (nonatomic, strong) NSString *externalProvider;
@property (nonatomic, strong) NSString *subtype;

@property (nonatomic) int commentCount;
@property (nonatomic) int likeCount;

@property (nonatomic, strong) STKUser *creator;
@property (nonatomic, strong) STKPost *originalPost;
@property (nonatomic, strong) NSSet *derivativePosts;
@property (nonatomic, strong) STKUser *accoladeReceiver;

@property (nonatomic, strong) NSSet *likes;
@property (nonatomic, strong) NSSet *hashTags;
@property (nonatomic, strong) NSSet *comments;
@property (nonatomic, strong) STKUser *fInverseFeed;
@property (nonatomic, strong) STKUser *fInverseProfile;
@property (nonatomic, strong) NSSet *activities;
@property (nonatomic, strong) NSSet *tags;

- (BOOL)isPostLikedByUser:(STKUser *)u;

- (UIImage *)typeImage;
- (UIImage *)disabledTypeImage;

@end
