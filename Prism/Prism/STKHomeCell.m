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

- (void)toggleLike:(id)sender
{
    ROUTE(sender);
}

- (void)showComments:(id)sender
{
    ROUTE(sender);
}

- (void)addToPrism:(id)sender
{
    ROUTE(sender);
}

- (void)sharePost:(id)sender
{
    ROUTE(sender);
}

- (void)pinPost:(id)sender
{
    ROUTE(sender);
}

- (void)cellDidLoad
{
    UIBarButtonItem * (^buttoner)(UIImage *, UIImage *, SEL) = ^(UIImage *n, UIImage *s, SEL action) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setImage:n forState:UIControlStateNormal];
        [b setImage:s forState:UIControlStateSelected];
        [b setImage:s forState:UIControlStateHighlighted];
        [b setFrame:CGRectMake(0, 0, [n size].width, [n size].height)];
        [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        
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
        buttoner([UIImage imageNamed:@"action_heart"], [UIImage imageNamed:@"action_heart_like"], @selector(toggleLike:)),
        flexer(),
        buttoner([UIImage imageNamed:@"action_comment"], [UIImage imageNamed:@"action_comment_active"], @selector(showComments:)),
        flexer(),
        buttoner([UIImage imageNamed:@"action_prism"], [UIImage imageNamed:@"action_prism_active"], @selector(addToPrism:)),
        flexer(),
        buttoner([UIImage imageNamed:@"action_share"], [UIImage imageNamed:@"action_share_selected"], @selector(sharePost:)),
        flexer(),
        buttoner([UIImage imageNamed:@"action_pin"], [UIImage imageNamed:@"action_pin_selected"], @selector(pinPost:)),
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
    
    [[[self iconImageView] layer] setCornerRadius:16];
    [[self iconImageView] setClipsToBounds:YES];
    
    
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
