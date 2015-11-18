//
//  STKProcessingViewController.m
//  NMFG
//
//  Created by Joe Conway on 5/22/13.
//  Copyright (c) 2013 NMFG. All rights reserved.
//

#import "STKProcessingView.h"
#import <QuartzCore/QuartzCore.h>


static STKProcessingView *STKProcessingViewCurrentView = nil;

@interface STKProcessingView ()

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation STKProcessingView

+ (void)present
{
    if(STKProcessingViewCurrentView != nil) {
        return;
    }
    STKProcessingView *p = [[STKProcessingView alloc] init];
    [p makeKeyAndVisible];
    STKProcessingViewCurrentView = p;
}

+ (void)presentForTime:(NSTimeInterval)timeInSeconds
{
    [self present];
    
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInSeconds * NSEC_PER_SEC));
    dispatch_after(t, dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}


+ (void)dismiss
{
    [STKProcessingViewCurrentView resignKeyWindow];
    STKProcessingViewCurrentView = nil;
}


- (id)init
{
    self = [super init];
    
    if (self) {
        self.frame = [[UIScreen mainScreen] bounds];
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
        [self setOpaque:NO];
        [self setWindowLevel:UIWindowLevelStatusBar + 1];
        
        UIActivityIndicatorView *iv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:iv];
        [self setActivityIndicator:iv];
        [[self activityIndicator] startAnimating];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [[self activityIndicator] setCenter:CGPointMake([self bounds].size.width / 2.0,
                                                    [self bounds].size.height / 2.0)];
}


@end
