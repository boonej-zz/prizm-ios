//
//  STKGenderCell.m
//  Prism
//
//  Created by Joe Conway on 12/10/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKGenderCell.h"
@interface STKGenderCell ()
- (IBAction)maleButtonTapped:(id)sender;
- (IBAction)femaleButtonTapped:(id)sender;
- (IBAction)notSetButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *backdropView;
@end

@implementation STKGenderCell

- (void)setBackdropColor:(UIColor *)backdropColor
{
    _backdropColor = backdropColor;
    [[self backdropView] setBackgroundColor:_backdropColor];
}

- (IBAction)maleButtonTapped:(id)sender
{
    [[self maleButton] setSelected:YES];
    [[self femaleButton] setSelected:NO];
    [[self notSetButton] setSelected:NO];
    ROUTE(sender);

}

- (IBAction)femaleButtonTapped:(id)sender
{
    [[self maleButton] setSelected:NO];
    [[self femaleButton] setSelected:YES];
    [[self notSetButton] setSelected:NO];
    ROUTE(sender);
}

- (IBAction)notSetButtonTapped:(id)sender
{
    [[self maleButton] setSelected:NO];
    [[self femaleButton] setSelected:NO];
    [[self notSetButton] setSelected:YES];
    ROUTE(sender);
}

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[self femaleButton] setTintColor:[UIColor clearColor]];
    [[self maleButton] setTintColor:[UIColor clearColor]];
    [[self notSetButton] setTintColor:[UIColor clearColor]];

}

- (void)layoutContent
{
    
}

@end
