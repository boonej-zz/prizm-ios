//
//  STKVerticalNavigationController.h
//  Prism
//
//  Created by Joe Conway on 12/5/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKVerticalNavigationController : UIViewController

- (id)initWithRootViewController:(UIViewController *)vc;
- (void)pushViewController:(UIViewController *)vc forSender:(UIView *)sender;

@property (nonatomic) BOOL backButtonHidden;

@end


@interface UIViewController (STKVerticalNavigationController)

- (STKVerticalNavigationController *)verticalController;

@end