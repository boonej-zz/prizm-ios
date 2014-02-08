//
//  STKProfileCell.m
//  Prism
//
//  Created by Joe Conway on 12/27/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKProfileCell.h"

@implementation STKProfileCell

- (void)cellDidLoad
{
    [[self nameLabel] setFont:STKFont(20)];
    [[self locationLabel] setFont:STKFont(12)];
    [[self nameLabel] setTextColor:STKTextColor];
    [[self locationLabel] setTextColor:STKTextTransparentColor];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [[_avatarView layer] setCornerRadius:16];
    [_avatarView setClipsToBounds:YES];

}

- (void)layoutContent
{
    
}

@end
