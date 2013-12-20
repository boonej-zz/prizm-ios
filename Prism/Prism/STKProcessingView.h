//
//  STKProcessingViewController.h
//  NMFG
//
//  Created by Joe Conway on 5/22/13.
//  Copyright (c) 2013 NMFG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKProcessingView : UIWindow

+ (void)present;
+ (void)presentForTime:(NSTimeInterval)timeInSeconds;

+ (void)dismiss;

@end
