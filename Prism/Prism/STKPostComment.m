//
//  STKPostComment.m
//  Prism
//
//  Created by Joe Conway on 2/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPostComment.h"
#import "STKUser.h"
#import "STKUserStore.h"

@implementation STKPostComment
- (NSError *)readFromJSONObject:(id)jsonObject
{
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    [self setDate:[df dateFromString:[jsonObject objectForKey:@"create_date"]]];
    [self setText:[jsonObject objectForKey:@"text"]];
    [self setCommentID:[jsonObject objectForKey:@"_id"]];
    
    [self setLikeCount:[[jsonObject objectForKey:@"likes_count"] intValue]];
    
    [self setLikedByCurrentUser:NO];
    for(NSDictionary *d in [jsonObject objectForKey:@"likes"]) {
        if([[d objectForKey:@"_id"] isEqualToString:[[[STKUserStore store] currentUser] userID]]) {
            [self setLikedByCurrentUser:YES];
        }
    }
    
    if([[jsonObject objectForKey:@"creator"] isKindOfClass:[NSDictionary class]]) {
        STKUser *u = [[STKUser alloc] init];
        [u readFromJSONObject:[jsonObject objectForKey:@"creator"]];
        [self setCreator:u];
    }
    
    return nil;
}
@end
