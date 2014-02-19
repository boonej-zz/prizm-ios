//
//  STKTriImageCell.m
//  Prism
//
//  Created by Joe Conway on 1/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTriImageCell.h"

@implementation STKTriImageCell

- (void)cellDidLoad
{
    [[self contentView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"v" : [self contentView]}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"v" : [self contentView]}]];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

- (IBAction)leftImageButtonTapped:(id)sender
{
    ROUTE(sender);
}

- (IBAction)centerImageButtonTapped:(id)sender
{
    ROUTE(sender);
}
- (IBAction)rightImageButtonTapped:(id)sender
{
    ROUTE(sender);
}
@end
