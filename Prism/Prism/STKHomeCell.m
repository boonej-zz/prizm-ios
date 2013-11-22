//
//  STKHomeCell.m
//  Prism
//
//  Created by Joe Conway on 11/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKHomeCell.h"

@implementation STKHomeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)cellDidLoad
{
    UIBarButtonItem * (^buttoner)(UIImage *, UIImage *) = ^(UIImage *n, UIImage *s) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setImage:n forState:UIControlStateNormal];
        [b setImage:s forState:UIControlStateSelected];
        [b setImage:s forState:UIControlStateHighlighted];
        [b setFrame:CGRectMake(0, 0, [n size].width, [n size].height)];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:b];
        
        return bbi;
    };
    
    UIBarButtonItem * (^flexer)() = ^{
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil action:nil];
        return bbi;
    };
    
    [[self bottomToolbar] setItems:@[
        flexer(),
        buttoner([UIImage imageNamed:@"action_heart"], [UIImage imageNamed:@"action_heart_like"]),
        flexer(),
        buttoner([UIImage imageNamed:@"action_comment"], [UIImage imageNamed:@"action_comment_active"]),
        flexer(),
        buttoner([UIImage imageNamed:@"action_prism"], [UIImage imageNamed:@"action_prism_active"]),
        flexer(),
        buttoner([UIImage imageNamed:@"action_share"], [UIImage imageNamed:@"action_share_selected"]),
        flexer(),
        buttoner([UIImage imageNamed:@"action_pin"], [UIImage imageNamed:@"action_pin_selected"]),
        flexer()
    ]];
    
    static UIImage *fadeImage = nil;
    if(!fadeImage) {
        UIGraphicsBeginImageContext(CGSizeMake(2, 2));
        [[UIColor colorWithRed:0.06 green:0.15 blue:0.40 alpha:0.95] set];
        UIRectFill(CGRectMake(0, 0, 2, 2));
        fadeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [[self backdropFadeView] setImage:fadeImage];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
