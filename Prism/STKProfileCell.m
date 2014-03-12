//
//  STKProfileCell.m
//  Prism
//
//  Created by Joe Conway on 12/27/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKProfileCell.h"

@interface STKProfileCell ()
@property (nonatomic) BOOL showPrismImageForToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
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

- (IBAction)toggleInformation:(id)sender
{
    [self setShowPrismImageForToggleButton:![self showPrismImageForToggleButton]];

    if([self showPrismImageForToggleButton]) {
        [[self toggleButton] setImage:[UIImage imageNamed:@"btn_prismbtn"]
                             forState:UIControlStateNormal];
    } else {
        [[self toggleButton] setImage:[UIImage imageNamed:@"btn_info"]
                             forState:UIControlStateNormal];
    }
    
    ROUTE(sender);
}

@end
