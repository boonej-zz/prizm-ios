//
//  STKCommentCell.m
//  Prism
//
//  Created by Joe Conway on 1/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCommentCell.h"
#import "STKResolvingImageView.h"

@import QuartzCore;

@implementation STKCommentCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[[self avatarImageView] layer] setCornerRadius:20];
    
    [[self avatarImageView] setClipsToBounds:YES];

}

- (void)layoutContent
{
    
}

@end
