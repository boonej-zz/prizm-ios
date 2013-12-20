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

NSString * const STKProfileInformationExternalServiceTwitter = @"Twitter";
NSString * const STKProfileInformationExternalServiceFacebook = @"Facebook";
NSString * const STKProfileInformationExternalServiceGoogle = @"Google";

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
    
    return pi;
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
        [self setExternalService:STKProfileInformationExternalServiceFacebook];
    }
    
    v = [d objectForKey:@"email"];
    if(v)
        [self setEmail:v];
    
    v = [d objectForKey:@"gender"];
    if(v)
        [self setGender:v];
    
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
        [self setExternalService:STKProfileInformationExternalServiceTwitter];
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
    if([[vals gender] isEqualToString:@"male"] || [[vals gender] isEqualToString:@"female"])
        [self setGender:[vals gender]];
    [self setFirstName:[[vals name] givenName]];
    [self setLastName:[[vals name] familyName]];
    [self setExternalID:[vals identifier]];
    [self setExternalService:STKProfileInformationExternalServiceGoogle];

    [self setProfilePhotoURLString:[[vals image] url]];
    [self setCoverPhotoURLString:[[[vals cover] coverPhoto] url]];
}

@end
