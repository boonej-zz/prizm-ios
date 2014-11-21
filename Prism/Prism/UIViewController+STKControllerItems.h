//
//  UIViewController+STKControllerItems.h
//  Prism
//
//  Created by Joe Conway on 11/11/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKMenuController.h"

@interface UIViewController (STKMenuControllerExtensions)

@property (nonatomic, readonly) UIBarButtonItem *menuBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *postBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *settingsBarButtonItem;

@property (nonatomic, readonly) STKMenuController *menuController;

- (UIBarButtonItem *)backButtonItem;

- (void)menuWillAppear:(BOOL)animated;
- (void)menuWillDisappear:(BOOL)animated;
- (void)addBlurViewWithHeight:(double)height;
- (void)addBackgroundImage;
- (void)handleUserUpdate;

@end
