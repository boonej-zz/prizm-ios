//
//  STKProfile.m
//  Prism
//
//  Created by Joe Conway on 1/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKProfile.h"
#import "STKUser.h"

NSString * const STKProfileTypePersonal = @"1";
NSString * const STKProfileTypeLuminary = @"2";
NSString * const STKProfileTypeMilitary = @"3";
NSString * const STKProfileTypeEducation = @"4";
NSString * const STKProfileTypeFoundation = @"5";
NSString * const STKProfileTypeCompa = @"6";
NSString * const STKProfileTypeCommunity = @"7";


NSString * const STKProfileCoverPhotoURLStringKey = @"cover_image_file_path";
NSString * const STKProfileProfilePhotoURLStringKey = @"profile_image_file_path";


@implementation STKProfile

@dynamic profileID;
@dynamic profilePhotoPath;
@dynamic coverPhotoPath;
@dynamic profileType;
@dynamic name;
@dynamic city;
@dynamic state;
@dynamic user;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:
    @{
      @"profile" : @"profileID",
      @"name" : @"name",
      STKProfileProfilePhotoURLStringKey : @"profilePhotoPath",
      STKProfileCoverPhotoURLStringKey: @"coverPhotoPath",
      @"profile_type" : @"profileType",
      @"city" : @"city",
      @"region" : @"state"
    }];
    return nil;
}

@end
