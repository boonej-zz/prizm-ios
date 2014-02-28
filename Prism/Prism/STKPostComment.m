//
//  STKPostComment.m
//  Prism
//
//  Created by Joe Conway on 2/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPostComment.h"
#import "STKUser.h"

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
    
    if([[jsonObject objectForKey:@"creator"] isKindOfClass:[NSDictionary class]]) {
        STKUser *u = [[STKUser alloc] init];
        [u readFromJSONObject:[jsonObject objectForKey:@"creator"]];
        [self setUser:u];
    }
    
    return nil;
}
@end
