//
//  STKActivityIndicatorView.h
//  Activity
//
//  Created by Joe Conway on 4/15/14.
//  Copyright (c) 2014 Stable Kernel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKActivityIndicatorView : UIView

@property (nonatomic, strong) UIColor *tickColor;
@property (nonatomic) float progress;
@property (nonatomic) BOOL refreshing;

@end
