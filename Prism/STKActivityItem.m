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
NSString * const STKActivityItemTypeTrustAccepted = @"trust_accepted";
NSString * const STKActivityItemTypeRepost = @"repost";

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

    [self bindFromDictionary:jsonObject keyMap:@{
                                                 @"from" : @{STKJSONBindFieldKey : @"creator", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"to" : @{STKJSONBindFieldKey : @"notifiedUser", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"post_id" : @{STKJSONBindFieldKey : @"post", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"comment_id" : @{STKJSONBindFieldKey : @"comment", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"_id" : @"uniqueID",
                                                 @"action" : @"action",
                                                 @"has_been_viewed" : @"hasBeenViewed",
                                                 @"create_date" : ^(id inValue) {
                                                    [self setReferenceTimestamp:inValue];
                                                    [self setDateCreated:[STKTimestampFormatter dateFromString:inValue]];
                                                 }
                                                 
                                                 
    }];
    
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
    } else if ([[self action] isEqualToString:STKActivityItemTypeTrustAccepted]) {
        [str appendString:@"accepted your trust request."];
    } else if ([[self action] isEqualToString:STKActivityItemTypeRepost]) {
        [str appendString:@"reposted your post."];
    }
    
    
    
    return [str copy];

}

@end
