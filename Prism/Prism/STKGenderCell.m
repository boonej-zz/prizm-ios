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
@end

@implementation STKGenderCell

- (IBAction)maleButtonTapped:(id)sender
{
    [[self maleButton] setSelected:YES];
    [[self femaleButton] setSelected:NO];
    ROUTE(sender);

}

- (IBAction)femaleButtonTapped:(id)sender
{
    [[self maleButton] setSelected:NO];
    [[self femaleButton] setSelected:YES];
    ROUTE(sender);
}

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[self femaleButton] setTintColor:[UIColor clearColor]];
    [[self maleButton] setTintColor:[UIColor clearColor]];
    
    UIGraphicsBeginImageContextWithOptions([[self maleButton] bounds].size, NO, 0.0);
    [[UIColor colorWithRed:0.0 green:0.5 blue:0.8 alpha:0.5] set];
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 30, 30)];
    [bp fill];
    [[self maleButton] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateNormal];
    [[UIColor colorWithRed:0.0 green:0.5 blue:0.8 alpha:1.0] set];
    bp = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMake(0, 0, 30, 30), 6, 6)];
    [bp fill];
    [[self maleButton] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateSelected];
    [[self maleButton] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateHighlighted];
    UIGraphicsEndImageContext();

    
    UIGraphicsBeginImageContextWithOptions([[self femaleButton] bounds].size, NO, 0.0);
    [[UIColor colorWithRed:0.8 green:0.0 blue:0.5 alpha:0.5] set];
    bp = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 30, 30)];
    [bp fill];
    [[self femaleButton] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateNormal];

    [[UIColor colorWithRed:0.8 green:0.0 blue:0.5 alpha:1.0] set];
    bp = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMake(0, 0, 30, 30), 6, 6)];
    [bp fill];
    [[self femaleButton] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateHighlighted];
    [[self femaleButton] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateSelected];
    UIGraphicsEndImageContext();
}

- (void)layoutContent
{
    
}

@end
