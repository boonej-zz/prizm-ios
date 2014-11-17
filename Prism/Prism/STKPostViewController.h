//
//  STKPostViewController.h
//  Prism
//
//  Created by Joe Conway on 1/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKPost, STKPostViewController, STKProfile, UIERealTimeBlurView;

@interface STKPostViewController : UIViewController

@property (nonatomic, strong) STKPost *post;

- (void)setBlurView:(UIERealTimeBlurView *)blurView;


@end
