//
//  STKPost.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKPost.h"
#import "STKUser.h"


@implementation STKPost

@dynamic authorName;
@dynamic postOrigin;
@dynamic authorUserID;
@dynamic datePosted;
@dynamic iconURLString;
@dynamic hashTagsData;
@dynamic imageURLString;
@dynamic user;
@synthesize hashTags = _hashTags;

- (NSArray *)hashTags
{
    if(!_hashTags) {
        if([[self hashTagsData] length] > 0) {
            _hashTags = [NSJSONSerialization JSONObjectWithData:[self hashTagsData]
                                                        options:0
                                                          error:nil];
        } else {
            _hashTags = @[];
        }
    }
    return _hashTags;
}

@end
