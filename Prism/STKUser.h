//
//  STKUser.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"
#import "STKProfileInformation.h"
#import "STKProfile.h"

@class STKActivityItem, STKPost, STKRequestItem;

extern NSString * const STKUserGenderMale;
extern NSString * const STKUserGenderFemale;

extern NSString * const STKUserExternalSystemFacebook;
extern NSString * const STKUserExternalSystemTwitter;
extern NSString * const STKUserExternalSystemGoogle;

extern CGSize STKUserCoverPhotoSize;
extern CGSize STKUserProfilePhotoSize;

extern NSString * const STKUserTypePersonal;
extern NSString * const STKUserTypeLuminary;
extern NSString * const STKUserTypeMilitary;
extern NSString * const STKUserTypeEducation;
extern NSString * const STKUserTypeFoundation;
extern NSString * const STKUserTypeCompany;
extern NSString * const STKUserTypeCommunity;


extern NSString * const STKUserCoverPhotoURLStringKey;
extern NSString * const STKUserProfilePhotoURLStringKey;


@interface STKUser : NSManagedObject <STKJSONObject>

@property (nonatomic) NSString *userID;

@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *zipCode;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;

@property (nonatomic, strong) NSString *coverPhotoPath;
@property (nonatomic, strong) NSString *profilePhotoPath;

@property (nonatomic, strong) NSString *externalServiceType;
@property (nonatomic, strong) NSString *accountStoreID;

@property (nonatomic) int32_t followerCount;
@property (nonatomic) int32_t followingCount;
@property (nonatomic) int32_t postCount;

- (NSString *)name;

@end

