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

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", [self firstName], [self lastName]];
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        decodeObject(_birthday);
        decodeObject(_userID);
        decodeObject(_firstName);
        decodeObject(_lastName);
        decodeObject(_zipCode);
        decodeObject(_email);
        decodeObject(_gender);
        decodeObject(_city);
        decodeObject(_state);
        decodeObject(_coverPhotoPath);
        decodeObject(_profilePhotoPath);
        decodeObject(_externalServiceType);
        decodeObject(_accountStoreID);
        
        _followerCount = [coder decodeIntForKey:@"_followerCount"];
        _followingCount = [coder decodeIntForKey:@"_followingCount"];
        _postCount = [coder decodeIntForKey:@"_postCount"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    encodeObject(_birthday);
    encodeObject(_userID);
    encodeObject(_firstName);
    encodeObject(_lastName);
    encodeObject(_zipCode);
    encodeObject(_email);
    encodeObject(_gender);
    encodeObject(_city);
    encodeObject(_state);
    encodeObject(_coverPhotoPath);
    encodeObject(_profilePhotoPath);
    encodeObject(_externalServiceType);
    encodeObject(_accountStoreID);
    
    [coder encodeInt:_followingCount forKey:@"_followingCount"];
    [coder encodeInt:_followerCount forKey:@"_followerCount"];
    [coder encodeInt:_postCount forKey:@"_postCount"];
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
        @"posts_count" : @"postCount",
        @"provider" : @"externalServiceType",
        @"info" : @"blurb",
        @"website" : @"website",
        STKUserProfilePhotoURLStringKey : @"profilePhotoPath",
        STKUserCoverPhotoURLStringKey : @"coverPhotoPath",
        @"birthday" : ^(id inValue) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM-dd-yyyy"];
            [self setBirthday:[df dateFromString:inValue]];
        }
    }];
    
    NSString *currentUserID = [[[STKUserStore store] currentUser] userID];
    
    BOOL isFollower = [[[jsonObject objectForKey:@"followers"] valueForKey:@"_id"] containsObject:currentUserID];
    [self setIsFollowedByCurrentUser:isFollower];
    
    BOOL isFollowing = [[[jsonObject objectForKey:@"following"] valueForKey:@"_id"] containsObject:currentUserID];
    [self setIsFollowingCurrentUser:isFollowing];
    
    if(![self trusts])
        [self setTrusts:[[NSMutableArray alloc] init]];
    
    for(NSDictionary *d in [jsonObject objectForKey:@"trusts"]) {
        STKTrust *t = [[STKTrust alloc] init];
        [t readFromJSONObject:d];
        [[self trusts] addObject:t];
        [t setOwningUser:self];
    }
    
    return nil;
}

- (STKTrust *)trustForUser:(STKUser *)u
{
    for(STKTrust *t in [self trusts]) {
        if([[t otherUser] isEqual:u]) {
            return t;
        }
    }
    return nil;
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[STKUser class]]) {
        if([[(STKUser *)object userID] isEqualToString:[self userID]])
            return YES;
    }
    return NO;
}


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
