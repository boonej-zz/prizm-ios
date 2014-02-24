//
//  STKUser.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKUser.h"
#import "STKActivityItem.h"
#import "STKPost.h"
#import "STKRequestItem.h"


NSString * const STKUserGenderMale = @"male";
NSString * const STKUserGenderFemale = @"female";

NSString * const STKUserExternalSystemFacebook = @"facebook";
NSString * const STKUserExternalSystemTwitter = @"twitter";
NSString * const STKUserExternalSystemGoogle = @"google";

NSString * const STKUserTypePersonal = @"personal";
NSString * const STKUserTypeLuminary = @"luminary";
NSString * const STKUserTypeMilitary = @"military";
NSString * const STKUserTypeEducation = @"education";
NSString * const STKUserTypeFoundation = @"foundation";
NSString * const STKUserTypeCompany = @"company";
NSString * const STKUserTypeCommunity = @"community";

NSString * const STKUserCoverPhotoURLStringKey = @"cover_photo_url";
NSString * const STKUserProfilePhotoURLStringKey = @"profile_photo_url";

CGSize STKUserCoverPhotoSize = {.width = 320, .height = 188};
CGSize STKUserProfilePhotoSize = {.width = 128, .height = 128};


@implementation STKUser

@dynamic userID;
@dynamic email;
@dynamic gender;
@dynamic city, state;
@dynamic zipCode, birthday, firstName, lastName, externalServiceType;
@dynamic accountStoreID;
@dynamic profilePhotoPath, coverPhotoPath;
@dynamic followerCount, followingCount, postCount;

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", [self firstName], [self lastName]];
}


- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:
    @{
        @"_id" : @"userID",
        @"email" : @"email",
        @"gender" : @"gender",
        @"first_name" : @"firstName",
        @"last_name" : @"lastName",
        @"zip_postal" : @"zipCode",
        @"city" : @"city",
        @"state" : @"state",
        @"followers_count" : @"followerCount",
        @"following_count" : @"followingCount",
//        @"posts_count" : @"postCount",
        STKUserProfilePhotoURLStringKey : @"profilePhotoPath",
        STKUserCoverPhotoURLStringKey : @"coverPhotoPath",
        @"birthday" : ^(id inValue) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM-dd-yyyy"];
            [self setBirthday:[df dateFromString:inValue]];
        }
    }];
    
    return nil;
}


@end
