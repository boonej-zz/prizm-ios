//
//  UIViewController+STKControllerItems.m
//  Prism
//
//  Created by Joe Conway on 11/11/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "UIViewController+STKControllerItems.h"
#import "STKCreatePostViewController.h"
#import "STKMenuController.h"
#import "STKNavigationButton.h"
#import "STKUserStore.h"
#import "HAFastSwitchViewController.h"
#import "UIERealTimeBlurView.h"

#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f

@implementation UIViewController (STKMenuControllerExtensions)

- (UIBarButtonItem *)backButtonItem
{
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    return bbi;
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (STKMenuController *)menuController
{
    UIViewController *parent = [self parentViewController];
    while(parent != nil) {
        if([parent isKindOfClass:[STKMenuController class]])
            return (STKMenuController *)parent;
        
        parent = [parent parentViewController];
    }
    return nil;
}

- (void)menuWillAppear:(BOOL)animated
{
    for(UIViewController *vc in [self childViewControllers]) {
        [vc menuWillAppear:animated];
    }
}

- (void)menuWillDisappear:(BOOL)animated
{
    for(UIViewController *vc in [self childViewControllers]) {
        [vc menuWillDisappear:animated];
    }
}

- (UIBarButtonItem *)settingsBarButtonItem
{
    STKNavigationButton *view = [[STKNavigationButton alloc] init];
    [view setImage:[UIImage imageNamed:@"btn_settings"]];
    [view setHighlightedImage:[UIImage imageNamed:@"btn_settings"]];
    [view setOffset:8];
    
    [view addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    return bbi;
}


- (UIBarButtonItem *)postBarButtonItem
{
    STKNavigationButton *view = [[STKNavigationButton alloc] init];
    [view addTarget:self action:@selector(createNewPost:) forControlEvents:UIControlEventTouchUpInside];
    [view setOffset:9];

    [view setImage:[UIImage imageNamed:@"btn_addcontent"]];
    [view setHighlightedImage:[UIImage imageNamed:@"btn_addcontent_active"]];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    return bbi;
}

- (UIBarButtonItem *)menuBarButtonItem
{
    STKNavigationButton *view = [[STKNavigationButton alloc] init];
    [view addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
//    BOOL longPressExists = NO;
//    for (id obj in view.gestureRecognizers) {
//        if ([obj isKindOfClass:[UILongPressGestureRecognizer class]]) {
//            longPressExists = YES;
//        }
//    }
//    if (! longPressExists){
//        UIGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showFastSwitchMenu:)];
//        [view addGestureRecognizer:longPressRecognizer];
//    }
    
    [view setImage:[UIImage imageNamed:@"btn_menu"]];
    [view setHighlightedImage:[UIImage imageNamed:@"btn_menu_active"]];
    [view setOffset:-11];
    [view setBadgeable:YES];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    
    return bbi;
}


- (void)createNewPost:(id)sender
{
    STKCreatePostViewController *cpc = [[STKCreatePostViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cpc];
    [self presentViewController:nvc animated:YES completion:^{
        [[self menuController] setMenuVisible:NO];
    }];
}

- (void)addBackgroundImage
{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage HABackgroundImage]];
    [iv setFrame:[self.view bounds]];
    iv.tag = 8900;
    [self.view insertSubview:iv atIndex:0];
}

- (void)handleUserUpdate
{
    UIImageView *iv = (UIImageView *)[self.view viewWithTag:8900];
    if (iv){
        [iv setImage:[UIImage HABackgroundImage]];
    }
}


- (void)toggleMenu:(id)sender
{
    STKMenuController *tbc = (STKMenuController *)[self menuController];
    [tbc setMenuVisible:![tbc isMenuVisible] animated:YES];
}

- (void)initiateSearch:(id)sender
{
    
}

- (void)showSettings:(id)sender
{
    
}

- (void)addBlurViewWithHeight:(double)height
{
   
    
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.size.height = height;
    UIView *view = nil;
    
    if (IS_HEIGHT_GTE_568 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        view = [[UIVisualEffectView alloc] initWithEffect:blur];
        [view setFrame:frame];
        UIView *dv = [[UIView alloc] initWithFrame:frame];
        [dv setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.34f]];
//        UIVibrancyEffect *ve = [UIVibrancyEffect effectForBlurEffect:blur];
//        UIVisualEffectView *vev = [[UIVisualEffectView alloc] initWithEffect:ve];
//        [vev setFrame:frame];
        
//        [[(UIVisualEffectView *)view contentView] addSubview:vev];
        [[(UIVisualEffectView *)view contentView] addSubview:dv];
    } else {
        view = [[UIImageView alloc] initWithFrame:frame];
        [view  setTag:15000];
        [(UIImageView *)view setImage:[UIImage HABackgroundImage]];
        [(UIImageView *)view setContentMode:UIViewContentModeTopLeft];
        [view setAlpha:0.95];
        [view setClipsToBounds:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBlurView) name:@"UserDetailsUpdated"object:nil];
        
    }
    
    [self.view addSubview:view];
    NSArray *horizontalConstatraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v(>=300)]-0-|" options:0 metrics:nil views:@{@"v": view}];
    NSString *verticalString = [NSString stringWithFormat:@"V:[v(%f)]", height];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalString options:0 metrics:nil views:@{@"v": view}];
    view.tag = 99999;
    [self.view addConstraints:horizontalConstatraints];
    [self.view addConstraints:verticalConstraints];
    NSLog(@"%@", [self class]);
    
}

- (void)refreshBlurView
{
    UIImageView *iv = (UIImageView *)[self.view viewWithTag:15000];
    if (iv){
        [iv setImage:[UIImage HABackgroundImage]];
    }
}

@end
