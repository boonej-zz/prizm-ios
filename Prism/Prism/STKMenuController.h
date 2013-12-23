//
//  STKNavigationController.h
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKMenuController : UIViewController

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController *selectedViewController;
@property (nonatomic, getter = isMenuVisible) BOOL menuVisible;

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;

- (void)logout;

@end
