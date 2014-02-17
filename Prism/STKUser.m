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


@implementation STKUser

@dynamic userID;
@dynamic userName;
@dynamic email;
@dynamic gender;
@dynamic requestItems;
@dynamic activityItems;
@dynamic posts;
@dynamic city, state;
@dynamic zipCode, birthday, firstName, lastName, externalServiceType;
@dynamic accountStoreID;
@dynamic profiles;

- (void)awakeFromInsert
{
    STKProfile *profile = [NSEntityDescription insertNewObjectForEntityForName:@"STKProfile"
                                                        inManagedObjectContext:[self managedObjectContext]];
    [profile setProfileType:STKProfileTypePersonal];
    [profile setUser:self];

}

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:
    @{
        @"_id" : @"userID",
        @"email" : @"email",
        @"gender" : @"gender",
        @"username" : @"userName",
        @"first_name" : @"firstName",
        @"last_name" : @"lastName",
        @"zip_postal" : @"zipCode",
        @"city" : @"city",
        @"state" : @"state",
        @"birthday" : ^(id inValue) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"YYYY-MM-dd"];
            [self setBirthday:[df dateFromString:inValue]];
        }
    }];
    
    STKProfile *profile = [self personalProfile];
    [profile readFromJSONObject:[jsonObject objectForKey:@"profile"]];
    [profile setUser:self];
    
    return nil;
}

- (STKProfile *)personalProfile
{
    for(STKProfile *p in [self profiles]) {
        if([[p profileType] isEqualToString:STKProfileTypePersonal]) {
            return p;
        }
    }
    return nil;
}

@end
