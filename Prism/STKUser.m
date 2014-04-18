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
#import "STKTrust.h"
#import "STKUserStore.h"

NSString * const STKUserGenderMale = @"male";
NSString * const STKUserGenderFemale = @"female";

NSString * const STKUserExternalSystemFacebook = @"facebook";
NSString * const STKUserExternalSystemTwitter = @"twitter";
NSString * const STKUserExternalSystemGoogle = @"google";

NSString * const STKUserTypePersonal = @"user";
NSString * const STKUserTypeLuminary = @"luminary";
NSString * const STKUserTypeMilitary = @"military";
NSString * const STKUserTypeInstitution = @"institution";
NSString * const STKUserTypeFoundation = @"foundation";
NSString * const STKUserTypeCompany = @"company";
NSString * const STKUserTypeCommunity = @"community";

NSString * const STKUserCoverPhotoURLStringKey = @"cover_photo_url";
NSString * const STKUserProfilePhotoURLStringKey = @"profile_photo_url";

CGSize STKUserCoverPhotoSize = {.width = 320, .height = 188};
CGSize STKUserProfilePhotoSize = {.width = 128, .height = 128};


@implementation STKUser
@dynamic uniqueID, birthday, city, dateCreated, email, firstName, lastName, externalServiceID, externalServiceType,
state, zipCode, gender, blurb, website, coverPhotoPath, profilePhotoPath, religion, ethnicity, followerCount, followingCount,
followers, following, postCount, ownedTrusts, receivedTrusts, comments, createdPosts, likedComments, likedPosts, fFeedPosts,
accountStoreID, instagramLastMinID, instagramToken, lastIntegrationSync;
@dynamic fProfilePosts, createdActivities, ownedActivities, twitterID, twitterLastMinID, type, dateFounded, enrollment, mascotName;
@synthesize profilePhoto, coverPhoto, token, secret, password;


- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", [self firstName], [self lastName]];
}

+ (NSDictionary *)reverseKeyMap
{
    return @{
             @"city" : @"city",
             @"uniqueID" : @"_id",
             @"email" : @"email",
             @"firstName" : @"first_name",
             @"lastName" : @"last_name",
             @"state" : @"state",
             @"zipCode" : @"zip_postal",
             @"gender" : @"gender",
             @"blurb" : @"info",
             @"website" : @"website",
             @"religion" : @"religion",
             @"ethnicity" : @"ethnicity",
             @"type" : @"type",
             @"instagramToken" : @"instagram_token",
             @"instagramLastMinID" : @"instagram_min_id",
             @"coverPhotoPath" : STKUserCoverPhotoURLStringKey,
             @"profilePhotoPath" : STKUserProfilePhotoURLStringKey,
             @"birthday" : @"birthday",
             @"twitterID" : @"twitter_token",
             @"twitterLastMinID" : @"twitter_min_id",
             @"enrollment" : @"enrollment",
             @"dateFounded" : @"date_founded",
             @"mascotName" : @"mascot"
    };
}

- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self bindFromDictionary:@{@"_id" : jsonObject} keyMap:@{@"_id" : @"uniqueID"}];
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:
    @{
        @"_id" : @"uniqueID",
        @"city" : @"city",
        @"email" : @"email",
        @"first_name" : @"firstName",
        @"last_name" : @"lastName",
        @"type" : @"type",
        @"provider" : @"externalServiceType",
        @"provider_id" : @"externalServiceID",
        
        @"state" : @"state",
        @"zip_postal" : @"zipCode",
        @"gender" : @"gender",
        
        @"info" : @"blurb",
        @"website" : @"website",

        STKUserProfilePhotoURLStringKey : @"profilePhotoPath",
        STKUserCoverPhotoURLStringKey : @"coverPhotoPath",

        @"religion" : @"religion",
        @"ethnicity" : @"ethnicity",
        
        @"followers_count" : @"followerCount",
        @"following_count" : @"followingCount",
        @"posts_count" : @"postCount",

        @"instagram_token" : @"instagramToken",
        @"instagram_min_id" : @"instagramLastMinID",
        @"twitter_token" : @"twitterID",
        @"twitter_min_id" : @"twitterLastMinID",
        @"trusts" : @{STKJSONBindFieldKey : @"ownedTrusts", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
        @"followers" : @{STKJSONBindFieldKey : @"followers", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
        @"following" : @{STKJSONBindFieldKey : @"following", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
        
        @"mascot" : @"mascotName",
        @"enrollment" : ^(NSNumber *inValue) {
            if(inValue)
                [self setEnrollment:[NSString stringWithFormat:@"%@", inValue]];
        },
        @"date_founded" : ^(NSString *inValue) {
            [self setDateFounded:[STKTimestampFormatter dateFromString:inValue]];
        },
        
        @"birthday" : ^(NSString *inValue) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM-dd-yyyy"];
            [self setBirthday:[df dateFromString:inValue]];
        },
        @"create_date" : ^(NSString *inValue) {
            [self setDateCreated:[STKTimestampFormatter dateFromString:inValue]];
        }
    }];
// 5335c7c3d6e286c075144533
    return nil;
}

- (STKTrust *)trustForUser:(STKUser *)u
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"STKTrust"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"(creator == %@ and recepient == %@) or (creator == %@ and recepient == %@)",
                       self, u, u, self]];
    
    NSArray *results = [[self managedObjectContext] executeFetchRequest:req error:nil];
    
    return [results firstObject];
}

- (BOOL)isFollowedByUser:(STKUser *)u
{
    return [[self followers] member:u] != nil;
}

- (BOOL)isFollowingUser:(STKUser *)u
{
    return [[self following] member:u] != nil;
}

- (BOOL)hasTrusts
{
    if([[self ownedTrusts] count] > 0 || [[self receivedTrusts] count] > 0)
        return YES;

    return NO;
}

- (NSArray *)trusts
{
    NSMutableArray *a = [NSMutableArray array];
    [a addObjectsFromArray:[[self ownedTrusts] allObjects]];
    [a addObjectsFromArray:[[self receivedTrusts] allObjects]];
    return [a copy];
}

/////

- (void)setValuesFromFacebook:(NSDictionary *)d
{
    NSString *v = [d objectForKey:@"first_name"];
    if(v)
        [self setFirstName:v];
    
    v = [d objectForKey:@"last_name"];
    if(v)
        [self setLastName:v];
    
    v = [d objectForKey:@"id"];
    if(v) {
        [self setExternalServiceID:v];
        [self setExternalServiceType:STKUserExternalSystemFacebook];
    }
    
    v = [d objectForKey:@"email"];
    if(v)
        [self setEmail:v];
    
    v = [d objectForKey:@"gender"];
    if(v) {
        if([v isEqualToString:@"male"]) {
            [self setGender:STKUserGenderMale];
        }
        if([v isEqualToString:@"female"]) {
            [self setGender:STKUserGenderFemale];
        }
    }
    v = [d objectForKey:@"birthday"];
    if(v) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
        
        [self setBirthday:[df dateFromString:v]];
    }
}


- (void)setValuesFromTwitter:(NSArray *)vals
{
    NSDictionary *d = [vals firstObject];
    
    NSString *v = [d objectForKey:@"id_str"];
    if(v) {
        [self setExternalServiceID:v];
        [self setExternalServiceType:STKUserExternalSystemTwitter];
    }
    
    v = [d objectForKey:@"name"];
    if(v) {
        NSArray *comps = [v componentsSeparatedByString:@" "];
        if([comps count] >= 2) {
            [self setFirstName:[comps firstObject]];
            [self setLastName:[comps lastObject]];
        } else {
            [self setFirstName:v];
        }
    }
}

- (void)setValuesFromGooglePlus:(GTLPlusPerson *)vals
{
    if([vals birthday]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd"];
        [self setBirthday:[df dateFromString:[vals birthday]]];
    }
    if([[vals gender] isEqualToString:@"male"]) {
        [self setGender:STKUserGenderMale];
    }
    if([[vals gender] isEqualToString:@"female"]) {
        [self setGender:STKUserGenderFemale];
    }
    
    [self setFirstName:[[vals name] givenName]];
    [self setLastName:[[vals name] familyName]];
    [self setExternalServiceID:[vals identifier]];
    [self setExternalServiceType:STKUserExternalSystemGoogle];
    
    [self setProfilePhotoPath:[[vals image] url]];
    [self setCoverPhotoPath:[[[vals cover] coverPhoto] url]];
}


@end
