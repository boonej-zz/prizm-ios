//
//  STKProfileCell.m
//  Prism
//
//  Created by Joe Conway on 12/27/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKProfileCell.h"

@interface STKProfileCell ()

@end

@implementation STKProfileCell

- (IBAction)profileStateChanged:(id)sender
{
    ROUTE(sender);
}

- (void)cellDidLoad
{
    [[self nameLabel] setFont:STKFont(18)];
    [[self locationLabel] setFont:STKFont(12)];
    [[self nameLabel] setTextColor:STKTextColor];
    [[self locationLabel] setTextColor:STKTextTransparentColor];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}
// btn_info, action_prism, 
- (void)layoutContent
{
    
}
@end
