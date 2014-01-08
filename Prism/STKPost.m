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
@dynamic type;
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

- (UIImage *)typeImage
{
    return [[self class] imageForType:[self type]];
}

+ (UIImage *)imageForType:(STKPostType)t
{
    NSDictionary *m = @{@(STKPostTypeAchievement) : @"category_achievements",
                        @(STKPostTypeAspiration) : @"category_aspirations",
                        @(STKPostTypeExperience) : @"category_experiences",
                        @(STKPostTypeInspiration) : @"category_inspirations",
                        @(STKPostTypePassion) : @"category_passion"};
    
    NSString *imageName = m[@(t)];
    
    if(imageName) {
        return [UIImage imageNamed:imageName];
    }
    
    return nil;
}

@end
