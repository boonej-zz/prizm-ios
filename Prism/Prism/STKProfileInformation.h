//
//  STKProfileInformation.h
//  Prism
//
//  Created by Joe Conway on 12/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLPlusPerson, CLPlacemark;

extern NSString * const STKProfileInformationExternalServiceTwitter;
extern NSString * const STKProfileInformationExternalServiceFacebook;
extern NSString * const STKProfileInformationExternalServiceGoogle;

@interface STKProfileInformation : NSObject <NSCopying>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;


@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, strong) NSString *profilePhotoURLString;
@property (nonatomic, strong) UIImage *coverPhoto;
@property (nonatomic, strong) NSString *coverPhotoURLString;

@property (nonatomic, strong) NSString *externalID;
@property (nonatomic, strong) NSString *externalService;
@property (nonatomic, strong) NSString *accountStoreID;

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *secret;

@property (nonatomic, strong) NSString *password;

- (void)setValuesFromFacebook:(NSDictionary *)vals;
- (void)setValuesFromTwitter:(NSArray *)vals;
- (void)setValuesFromGooglePlus:(GTLPlusPerson *)vals;

- (void)setLocation:(CLPlacemark *)cp;

@end
