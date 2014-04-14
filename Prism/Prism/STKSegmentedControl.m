//
//  STKSegmentedControl.m
//  Prism
//
//  Created by Joe Conway on 4/13/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSegmentedControl.h"

@implementation STKSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    // 'On state'
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    //[[UIColor colorWithRed:0.86 green:0.87 blue:.92 alpha:0.3] set];
    [STKSelectedColor set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [self setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext()
                                         forState:UIControlStateSelected
                                       barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
    
    [self setTitleTextAttributes:@{NSFontAttributeName : STKFont(16),
                                                        NSForegroundColorAttributeName : STKSelectedTextColor}
                                             forState:UIControlStateSelected];
    
    
    // 'Off' state
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [STKUnselectedColor set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [self setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext()
                                         forState:UIControlStateNormal
                                       barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
    [self setTitleTextAttributes:@{NSFontAttributeName : STKFont(16),
                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}
                                             forState:UIControlStateNormal];
    
    // Divider
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [[UIColor colorWithRed:74.0/255.0 green:114.0/255.0 blue:153.0/255.0 alpha:0.8] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [self setDividerImage:UIGraphicsGetImageFromCurrentImageContext()
                           forLeftSegmentState:UIControlStateNormal
                             rightSegmentState:UIControlStateNormal
                                    barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
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
