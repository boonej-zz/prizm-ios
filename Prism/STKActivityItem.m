//
//  STKActivity.m
//  Prism
//
//  Created by Joe Conway on 4/8/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKActivityItem.h"
#import "STKUser.h"

NSString * const STKActivityItemContextPost = @"post";
NSString * const STKActivityItemContextUser = @"user";
NSString * const STKActivityItemContextComment = @"comment";

NSString * const STKActivityItemActionCreate = @"create";
NSString * const STKActivityItemActionDelete = @"remove";

NSString * const STKActivityItemTypePost = @"post";
NSString * const STKActivityItemTypeFollow = @"follow";
NSString * const STKActivityItemTypeUnfollow = @"unfollow";
NSString * const STKActivityItemTypeLike = @"like";
NSString * const STKActivityItemTypeUnlike = @"unlike";
NSString * const STKActivityItemTypeComment = @"comment";


@implementation STKActivityItem

@dynamic uniqueID;
@dynamic action;
@dynamic context;
@dynamic type;
@dynamic dateCreated;
@dynamic hasBeenViewed;
@dynamic referenceTimestamp;
@dynamic targetID;
@dynamic creator;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }

    [self bindFromDictionary:jsonObject keyMap:@{
                                                 @"user" : @{STKJSONBindFieldKey : @"creator", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"target" : @"targetID",
                                                 @"_id" : @"uniqueID",
                                                 @"action" : @"action",
                                                 @"context" : @"context",
                                                 @"create_date" : ^(id inValue) {
                                                    [self setReferenceTimestamp:inValue];
                                                    [self setDateCreated:[df dateFromString:inValue]];
                                                 },
                                                 @"type" : @"type"
                                                 
                                                 
    }];
    
    [self setHasBeenViewed:NO];
    
    return nil;
}

- (NSString *)text
{
    if([[self type] isEqualToString:STKActivityItemTypeLike]) {
        if([[self action] isEqualToString:STKActivityItemActionCreate]) {
            return [NSString stringWithFormat:@"liked your %@", [self context]];
        }
    }
    if([[self type] isEqualToString:STKActivityItemTypeFollow]) {
        if([[self action] isEqualToString:STKActivityItemActionCreate]) {
            return [NSString stringWithFormat:@"started following you"];
        }
    }
    
    return @"";

}

@end
