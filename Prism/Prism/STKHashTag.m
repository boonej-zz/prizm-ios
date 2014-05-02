//
//  STKHashTag.m
//  Prism
//
//  Created by Joe Conway on 3/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKHashTag.h"
#import "STKPost.h"


@implementation STKHashTag

@dynamic title;
@dynamic posts;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self setTitle:[jsonObject lowercaseString]];
    
    return nil;
}

@end
