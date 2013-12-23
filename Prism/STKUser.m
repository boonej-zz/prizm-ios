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


@implementation STKUser

@dynamic userID;
@dynamic userName;
@dynamic email;
@dynamic gender;
@dynamic requestItems;
@dynamic activityItems;
@dynamic posts;

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
        @"date_of_birth" : ^(id inValue) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"YYYY-MM-dd"];
            [self setBirthday:[df dateFromString:inValue]];
        }
    }];
    return nil;
}

@end
