//
//  STKProfileInformation.m
//  Prism
//
//  Created by Joe Conway on 12/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKProfileInformation.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "STKUser.h"

@import CoreLocation;

@implementation STKProfileInformation

- (id)copyWithZone:(NSZone *)zone
{
    STKProfileInformation *pi = [[STKProfileInformation alloc] init];
    
    [pi setFirstName:[self firstName]];
    [pi setLastName:[self lastName]];
    [pi setEmail:[self email]];
    [pi setGender:[self gender]];
    [pi setBirthday:[self birthday]];
    [pi setZipCode:[self zipCode]];
    [pi setProfilePhoto:[self profilePhoto]];
    [pi setProfilePhotoURLString:[self profilePhotoURLString]];
    [pi setCoverPhoto:[self coverPhoto]];
    [pi setCoverPhotoURLString:[self coverPhotoURLString]];
    [pi setExternalID:[self externalID]];
    [pi setExternalService:[self externalService]];
    [pi setPassword:[self password]];
    [pi setToken:[self token]];
    [pi setSecret:[self secret]];
    [pi setAccountStoreID:[self accountStoreID]];
    [pi setCity:[self city]];
    [pi setState:[self state]];
    
    return pi;
}

- (void)transferValuesIntoUser:(STKUser *)user
{
#define STKT(x, y) if(x) [user setValue:x forKey:y]
    STKT([self firstName], @"firstName");
    STKT([self lastName], @"lastName");
    STKT([self email], @"email");
    STKT([self gender], @"gender");
    STKT([self birthday], @"birthday");
    STKT([self zipCode], @"zipCode");
    STKT([self externalID], @"externalServiceID");
    STKT([self externalService], @"externalServiceType");
    STKT([self accountStoreID], @"accountStoreID");
    STKT([self city], @"city");
    STKT([self state], @"state");
#undef STKT
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
        [self setExternalID:v];
        [self setExternalService:STKUserExternalSystemFacebook];
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
        [self setExternalID:v];
        [self setExternalService:STKUserExternalSystemTwitter];
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
    [self setExternalID:[vals identifier]];
    [self setExternalService:STKUserExternalSystemGoogle];

    [self setProfilePhotoURLString:[[vals image] url]];
    [self setCoverPhotoURLString:[[[vals cover] coverPhoto] url]];
}

@end
