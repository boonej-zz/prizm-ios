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

- (void)cellDidLoad
{
    [[self nameLabel] setFont:STKFont(20)];
    [[self locationLabel] setFont:STKFont(12)];
    [[self nameLabel] setTextColor:STKTextColor];
    [[self locationLabel] setTextColor:STKTextTransparentColor];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

- (void)setShowPrismImageForToggleButton:(BOOL)showPrismImageForToggleButton
{
    _showPrismImageForToggleButton = showPrismImageForToggleButton;
    
    [[self toggleButton] setSelected:_showPrismImageForToggleButton];
    
    if([self showPrismImageForToggleButton]) {
//        [[self toggleButton] setSelected:YES];
//        [[self toggleButton] setImage:[UIImage imageNamed:@"action_prism"]
//                             forState:UIControlStateNormal];
    } else {
//        [[self toggleButton] setImage:[UIImage imageNamed:@"btn_info"]
//                             forState:UIControlStateNormal];
    }

}

- (IBAction)toggleInformation:(id)sender
{
    [self setShowPrismImageForToggleButton:![self showPrismImageForToggleButton]];

    
    ROUTE(sender);
}

@end
