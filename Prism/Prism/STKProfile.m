//
//  STKProfile.m
//  Prism
//
//  Created by Joe Conway on 1/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKProfile.h"
#import "STKUser.h"




@implementation STKProfile

@dynamic accoladeCount, trustCount, followedCount, followingCount, postCount;
@dynamic profileID;
@dynamic profilePhotoPath;
@dynamic coverPhotoPath;
@dynamic profileType;
@dynamic name;
@dynamic city;
@dynamic state;
@dynamic user;
@dynamic entityID;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:
    @{
      @"entity" : @"entityID",
    //  STKProfileProfileIDKey : @"profileID",
      @"name" : @"name",
    //  STKProfileProfilePhotoURLStringKey : @"profilePhotoPath",
     // STKProfileCoverPhotoURLStringKey: @"coverPhotoPath",
      @"profile_type" : @"profileType",
      @"city" : @"city",
      @"region" : @"state",
      @"dv_profiles_followed_by_count" : @"followedCount",
      @"dv_profiles_following_count" : @"followingCount",
      @"dv_trust_count" : @"trustCount",
      @"dv_accolade_count" : @"accoladeCount",
      @"dv_created_post_count" : @"postCount"
    }];
    [self setProfilePhotoPath:[[self profilePhotoPath] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
    [self setCoverPhotoPath:[[self coverPhotoPath] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];

    return nil;
}

@end
