//
//  STKActivity.m
//  Prism
//
//  Created by Joe Conway on 4/8/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKActivityItem.h"
#import "STKUser.h"


NSString * const STKActivityItemTypePost = @"post";
NSString * const STKActivityItemTypeFollow = @"follow";
NSString * const STKActivityItemTypeUnfollow = @"unfollow";
NSString * const STKActivityItemTypeLike = @"like";
NSString * const STKActivityItemTypeUnlike = @"unlike";
NSString * const STKActivityItemTypeComment = @"comment";


@implementation STKActivityItem

@dynamic uniqueID;
@dynamic action;
@dynamic dateCreated;
@dynamic hasBeenViewed;
@dynamic referenceTimestamp;
@dynamic post, comment;
@dynamic creator, notifiedUser;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }

    [self bindFromDictionary:jsonObject keyMap:@{
                                                 @"from" : @{STKJSONBindFieldKey : @"creator", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"to" : @{STKJSONBindFieldKey : @"notifiedUser", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"post_id" : @{STKJSONBindFieldKey : @"post", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"comment_id" : @{STKJSONBindFieldKey : @"comment", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"_id" : @"uniqueID",
                                                 @"action" : @"action",
                                                 @"create_date" : ^(id inValue) {
                                                    [self setReferenceTimestamp:inValue];
                                                    [self setDateCreated:[df dateFromString:inValue]];
                                                 }
                                                 
                                                 
    }];
    
    [self setHasBeenViewed:NO];
    
    return nil;
}

- (NSString *)text
{
    NSMutableString *str = [[NSMutableString alloc] init];
    if([[self action] isEqualToString:STKActivityItemTypeLike]) {
        [str appendString:@"liked your "];

        if([self comment]) {
            [str appendString:@"comment."];
        } else if([self post]) {
            [str appendString:@"post."];
        }
    } else if([[self action] isEqualToString:STKActivityItemTypeComment]) {
        [str appendString:@"commented on your post."];
        
    } else if([[self action] isEqualToString:STKActivityItemTypeFollow]) {
        [str appendString:@"started following you."];
    }
    
    
    
    return [str copy];

}

@end
