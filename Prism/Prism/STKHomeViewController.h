//
//  STKHomeViewController.h
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIERealTimeBlurView;

@interface STKHomeViewController : UIViewController

@property (nonatomic, strong) UIView *blurView;

- (void)setBlurView:(UIView *)blurView;

@end
