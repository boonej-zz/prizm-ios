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

@interface STKCommentCell () <UITextViewDelegate>

@end

@implementation STKCommentCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [[[self textView] textContainer] setLineFragmentPadding:0];
    [[self textView] setTextContainerInset:UIEdgeInsetsZero];
//    [[self textView] setDelaysContentTouches:NO];
}

- (IBAction)toggleCommentLike:(id)sender
{
    ROUTE(sender);
}


- (void)layoutContent
{
    
}

- (IBAction)avatarTapped:(id)sender
{
    ROUTE(sender);
}

- (IBAction)showLikes:(id)sender
{
    ROUTE(sender);
}

@end
