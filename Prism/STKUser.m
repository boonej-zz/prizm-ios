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

NSString * const STKUserTypePersonal = @"Personal";
NSString * const STKUserTypeLuminary = @"Luminaries";
NSString * const STKUserTypeMilitary = @"Military";
NSString * const STKUserTypeEducation = @"Education";
NSString * const STKUserTypeFoundation = @"Foundations";
NSString * const STKUserTypeCompa = @"Companies";
NSString * const STKUserTypeCommunity = @"Community";


@implementation STKUser

@dynamic userID;
@dynamic userName;
@dynamic email;
@dynamic gender;
@dynamic requestItems;
@dynamic activityItems;
@dynamic posts;
@dynamic city, state;
@dynamic profileID;
@dynamic profilePhotoPath, coverPhotoPath;
@dynamic zipCode, birthday, firstName, lastName, externalServiceType;
@dynamic accountStoreID;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:
    @{
        @"entity" : @"userID",
        @"email_address" : @"email",
        @"gender" : @"gender",
        @"email_address" : @"userName",
        @"username" : @"userName",
        @"first_name" : @"firstName",
        @"last_name" : @"lastName",
        @"zip_postal" : @"zipCode",
        @"city" : @"city",
        @"region" : @"state",
        @"profile" : @"profileID",
        @"cover_image_file_path" : @"coverPhotoPath",
        @"profile_image_file_path" : @"profilePhotoPath",
        @"date_of_birth" : ^(id inValue) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"YYYY-MM-dd"];
            [self setBirthday:[df dateFromString:inValue]];
        }
    }];
    
    return nil;
}

@end
