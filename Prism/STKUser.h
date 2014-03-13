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


#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

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


@interface STKUser : NSObject <STKJSONObject, NSCoding>

@property (nonatomic) NSString *userID;

@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *zipCode;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;

@property (nonatomic, strong) NSString *blurb;
@property (nonatomic, strong) NSString *website;

@property (nonatomic, strong) NSString *coverPhotoPath;
@property (nonatomic, strong) NSString *profilePhotoPath;

@property (nonatomic, strong) NSString *externalServiceID;
@property (nonatomic, strong) NSString *externalServiceType;
@property (nonatomic, strong) NSString *accountStoreID;

@property (nonatomic) int followerCount;
@property (nonatomic) int followingCount;
@property (nonatomic) int postCount;

@property (nonatomic) BOOL isFollowedByCurrentUser;
@property (nonatomic) BOOL isFollowingCurrentUser;

- (NSString *)name;

// For auth/creating
@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, strong) UIImage *coverPhoto;

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *secret;

@property (nonatomic, strong) NSString *password;

- (void)setValuesFromFacebook:(NSDictionary *)vals;
- (void)setValuesFromTwitter:(NSArray *)vals;
- (void)setValuesFromGooglePlus:(GTLPlusPerson *)vals;


@end

