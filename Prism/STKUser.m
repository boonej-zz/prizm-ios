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

NSString * const STKUserGenderUnknown = @"unknown";

NSString * const STKUserExternalSystemFacebook = @"facebook";
NSString * const STKUserExternalSystemTwitter = @"twitter";
NSString * const STKUserExternalSystemGoogle = @"google";

NSString * const STKUserTypePersonal = @"user";
NSString * const STKUserTypeInstitution = @"institution_verified";
NSString * const STKUserTypeInstitutionPending = @"institution";

NSString * const STKUserSubTypeKey = @"council";
NSString * const STKUserSubTypeFoundation = @"foundation";
NSString * const STKUserSubTypeMilitary = @"military";
NSString * const STKUserSubTypeCompany = @"company";
NSString * const STKUserSubTypeCommunity = @"community";
NSString * const STKUserSubTypeEducation = @"education";
NSString * const STKUserSubTypeLuminary = @"luminary";

NSString *const STKIntroCompletedKey = @"STKIntroCompletedKey";
NSString *const STKPrivacyInstructionsDismissedKey = @"STKPrivacyInstructionsDismissed";

BOOL const STKUserStatusActive = YES;
BOOL const STKUserStatusInActive = NO;

CGSize STKUserCoverPhotoSize = {.width = 320, .height = 188};
CGSize STKUserProfilePhotoSize = {.width = 128, .height = 128};


@implementation STKUser
@dynamic uniqueID, birthday, city, interests, dateCreated, email, firstName, lastName, externalServiceID, externalServiceType,
state, zipCode, gender, blurb, website, coverPhotoPath, profilePhotoPath, religion, ethnicity, followerCount, followingCount,
followers, following, postCount, ownedTrusts, receivedTrusts, comments, createdPosts, likedComments, likedPosts, fFeedPosts,
accountStoreID, instagramLastMinID, instagramToken, phoneNumber, trustCount, active, dateDeleted, tumblrToken,
tumblrTokenSecret, tumblrLastMinID, programCode;
@dynamic fProfilePosts, createdActivities, ownedActivities, postsTaggedIn, twitterID, twitterLastMinID, type, dateFounded, enrollment, mascotName, subtype;
@synthesize profilePhoto, coverPhoto, token, secret, password;


- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", [self firstName], [self lastName]];
}

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id" : @"uniqueID",
             @"city" : @"city",
             @"email" : @"email",
             @"first_name" : @"firstName",
             @"last_name" : @"lastName",
             @"type" : @"type",
             @"provider" : @"externalServiceType",
             @"provider_id" : @"externalServiceID",
             @"program_code": @"programCode",
             
             @"subtype" : @"subtype",
             @"state" : @"state",
             @"zip_postal" : @"zipCode",
             @"gender" : @"gender",
             @"interests" : [STKBind bindMapForKey:@"interests" transform:^id(id inValue, STKTransformDirection direction) {
                 if ([inValue isKindOfClass:[NSArray class]]) {
                     return [inValue componentsJoinedByString:@","];
                 } else {
                     return @"";
                 }
             }],
             
             @"info" : @"blurb",
             @"website" : @"website",
             
             @"profile_photo_url" : @"profilePhotoPath",
             @"cover_photo_url" : @"coverPhotoPath",
             
             @"religion" : @"religion",
             @"ethnicity" : @"ethnicity",
             
             @"followers_count" : @"followerCount",
             @"following_count" : @"followingCount",
             @"posts_count" : @"postCount",
             @"trust_count" : @"trustCount",
             
             
             @"tumblr_token_secret" : @"tumblrTokenSecret",
             @"tumblr_token" : @"tumblrToken",
             @"tumblr_min_id" : @"tumblrLastMinID",
             @"instagram_token" : @"instagramToken",
             @"instagram_min_id" : @"instagramLastMinID",
             @"twitter_token" : @"twitterID",
             @"twitter_min_id" : @"twitterLastMinID",
             
             @"trusts" : [STKBind bindMapForKey:@"ownedTrusts" matchMap:@{@"uniqueID" : @"_id"}],

             @"followers" : [STKBind bindMapForKey:@"followers" matchMap:@{@"uniqueID" : @"_id"}],
             @"following" : [STKBind bindMapForKey:@"following" matchMap:@{@"uniqueID" : @"_id"}],
             @"phone_number" : @"phoneNumber",
             @"mascot" : @"mascotName",
             @"enrollment" : [STKBind bindMapForKey:@"enrollment" transform:^id(id inValue, STKTransformDirection direction) {
                 if(direction == STKTransformDirectionLocalToRemote) {
                     return @([inValue intValue]);
                 } else {
                     return [NSString stringWithFormat:@"%@", inValue];
                 }
             }],
             @"date_founded" : [STKBind bindMapForKey:@"dateFounded" transform:STKBindTransformDateTimestamp],
             
             @"birthday" : [STKBind bindMapForKey:@"birthday" transform:^id(id inValue, STKTransformDirection direction) {
                 NSDateFormatter *df = [[NSDateFormatter alloc] init];
                 [df setDateFormat:@"MM-dd-yyyy"];
                 if(direction == STKTransformDirectionLocalToRemote) {
                     return [df stringFromDate:inValue];
                 } else {
                     return [df dateFromString:inValue];
                 }
             }],
             @"create_date" : [STKBind bindMapForKey:@"dateCreated" transform:STKBindTransformDateTimestamp],
             @"delete_date" : [STKBind bindMapForKey:@"dateDeleted" transform:STKBindTransformDateTimestamp],
             @"active" : @"active"
    };
}


- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self bindFromDictionary:@{@"_id" : jsonObject} keyMap:@{@"_id" : @"uniqueID"}];
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

- (STKTrust *)trustForUser:(STKUser *)u
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"STKTrust"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"(creator == %@ and recepient == %@) or (creator == %@ and recepient == %@)",
                       self, u, u, self]];
    
    NSArray *results = [[self managedObjectContext] executeFetchRequest:req error:nil];
    NSLog(@"%@", [results valueForKey:@"uniqueID"]);
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

- (BOOL)shouldDisplayGraphInstructions
{
    return [self postCount] == 0;
}

- (BOOL)shouldDisplayHomeFeedInstructions
{
    return ([self postCount] + [self trustCount] + [self followingCount]) == 0;
}

- (BOOL)shouldDisplayTrustInstructions
{
    return [self trustCount] == 0;
}

- (BOOL)shouldDisplayIntroScreen
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:STKIntroCompletedKey];
}

- (BOOL)shouldDisplayPostInstructions
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:STKPrivacyInstructionsDismissedKey];
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

- (BOOL)isInstitution
{
    return [[self type] isEqualToString:STKUserTypeInstitution] || [[self type] isEqualToString:STKUserTypeInstitutionPending];
}

- (BOOL)isLuminary
{
    return [[self subtype] isEqualToString:STKUserSubTypeLuminary];
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

- (NSString *)age
{
    long age = 0;
    if (self.birthday){
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self.birthday toDate:[NSDate date] options:0];
        age = [ageComponents year];
    }
    
    return [NSString stringWithFormat:@"%ld", age];
}

- (NSDictionary *)mixpanelProperties
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-dd"];
    NSLog(@"%@", [self age]);
    return @{
             @"email": self.email?self.email:@"none",
             @"birthday": self.birthday?[df stringFromDate:self.birthday]:@"unknown",
             @"age": [self age],
             @"gender": self.gender?self.gender:@"unknown",
             @"city": self.city?self.city:@"unknown",
             @"state": self.state?self.state:@"unknown",
             @"zip": self.zipCode?self.zipCode:@"unknown"
             };
}

@end
