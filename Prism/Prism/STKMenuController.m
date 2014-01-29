//
//  STKNavigationController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKMenuController.h"
#import "STKMenuView.h"
#import "STKHomeViewController.h"
#import "STKExploreViewController.h"
#import "STKTrustViewController.h"
#import "STKProfileViewController.h"
#import "STKActivityViewController.h"
#import "STKGraphViewController.h"
#import "STKCreatePostViewController.h"
#import "STKRenderServer.h"
#import "STKUserStore.h"
#import "STKErrorStore.h"
#import "STKRegisterViewController.h"
#import "STKVerticalNavigationController.h"
#import "UIViewController+STKControllerItems.h"

@import QuartzCore;

@interface STKMenuController () <UINavigationControllerDelegate, STKMenuViewDelegate>

@property (nonatomic, strong) STKMenuView *menuView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) NSLayoutConstraint *menuTopConstraint;
@end

@implementation STKMenuController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userBecameUnauthorized:)
                                                     name:STKUserStoreCurrentUserSessionEndedNotification
                                                   object:nil];
    }
    return self;
}


- (void)userBecameUnauthorized:(NSNotification *)note
{
    NSString *reasonValue = [[note userInfo] objectForKey:STKUserStoreCurrentUserSessionEndedReasonKey];
    NSString *msg = nil;
    if([reasonValue isEqualToString:STKUserStoreCurrentUserSessionEndedConnectionValue]) {
        msg = @"There was an issue with your connection and you could not be authenticated with the server. Please make sure you have an internet connection and log in again.";
    } else if ([reasonValue isEqualToString:STKUserStoreCurrentUserSessionEndedAuthenticationValue]) {
        msg = @"Your session has ended. Please try to login again.";
    }
    
    // Only if we need a message do we show the alert view
    UIAlertView *av = nil;
    if(msg) {
        av = [[UIAlertView alloc] initWithTitle:@"Session Ended"
                                        message:msg
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    }
    STKRegisterViewController *rvc = [[STKRegisterViewController alloc] init];
    STKVerticalNavigationController *nvc = [[STKVerticalNavigationController alloc] initWithRootViewController:rvc];
    [self presentViewController:nvc animated:YES
                     completion:^{
                         [self recreateAllViewControllers];
                         [av show];
                     }];
    
}

- (void)recreateAllViewControllers
{
    NSMutableArray *vcTypes = [NSMutableArray array];
    for(UINavigationController *nvc in [self viewControllers]) {
        UIViewController *root = [[nvc viewControllers] firstObject];
        [vcTypes addObject:[root class]];
    }
    
    NSMutableArray *newVCs = [NSMutableArray array];
    for(Class cls in vcTypes) {
        UIViewController *vc = [[cls alloc] init];
        UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:vc];
        [newVCs addObject:newNav];
    }
    [self setViewControllers:[newVCs copy]];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if([self isViewLoaded]) {
        [[self backgroundImageView] setImage:_backgroundImage];
    }
}

- (void)setMenuVisible:(BOOL)menuVisible
{
    [self setMenuVisible:menuVisible animated:NO];
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated
{
    if(menuVisible) {
        [[self view] bringSubviewToFront:[self menuView]];

        CGRect blurRect = [[self view] bounds];
        
        UIViewController *selected = [self selectedViewController];
        if([selected isKindOfClass:[UINavigationController class]]) {
            UINavigationBar *bar = [(UINavigationController *)selected navigationBar];
            CGRect barFrame = [bar frame];
            float topOffset = barFrame.origin.y + barFrame.size.height;
            [[self menuTopConstraint] setConstant:topOffset];
            blurRect.origin.y += topOffset;
            blurRect.size.height -= topOffset;
        } else {
            [[self menuTopConstraint] setConstant:0];
        }
        
        [[self menuView] setBackgroundImage:[[STKRenderServer renderServer] instantBlurredImageForView:[self view]
                                                                                             inSubrect:blurRect]];
        
        [[self menuView] layoutIfNeeded];
    }
    [[self menuView] setVisible:menuVisible animated:animated];
}

- (BOOL)isMenuVisible
{
    return [[self menuView] isVisible];
}

- (STKMenuView *)menuView
{
    [self loadMenuIfRequired];
    return _menuView;
}

- (void)menuView:(STKMenuView *)menuView didSelectItemAtIndex:(int)idx
{
    [self setMenuVisible:NO animated:YES];
    UIViewController *vc = [[self viewControllers] objectAtIndex:idx];
    if(vc != [self selectedViewController])
        [self setSelectedViewController:vc];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [[[self selectedViewController] view] removeFromSuperview];
    
    _selectedViewController = selectedViewController;
    
    if([self isViewLoaded]) {
        UIView *v = [[self selectedViewController] view];
        [[self view] addSubview:v];
        [v setFrame:[[self view] bounds]];
        
        [[self menuView] setSelectedIndex:(int)[[self viewControllers] indexOfObject:_selectedViewController]];
    }
}

- (void)loadMenuIfRequired
{
    if(_menuView)
        return;
    
    _menuView = [[STKMenuView alloc] init];
    [[self menuView] setDelegate:self];
    [[self view] addSubview:[self menuView]];
    
    [[self menuView] setItems:[[self viewControllers] valueForKey:@"tabBarItem"]];
    
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{@"v" : _menuView}]];
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:_menuView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:[self view]
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1 constant:0];
    [[self view] addConstraint:c];
    _menuTopConstraint = c;
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:[self view]
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_menuView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1 constant:0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)toggleMenu:(id)sender
{
    [self setMenuVisible:![self isMenuVisible] animated:YES];
}

- (void)createNewPost:(id)sender
{
    [self setMenuVisible:NO animated:YES];
    
    STKCreatePostViewController *cvc = [[STKCreatePostViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    for(UIViewController *vc in [self viewControllers]) {
        
        [vc willMoveToParentViewController:nil];
        if(vc == [self selectedViewController])
            [[vc view] removeFromSuperview];
        [vc removeFromParentViewController];
    }
    
    _viewControllers = [viewControllers copy];

    for(UIViewController *vc in viewControllers) {
        if([vc isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)vc setDelegate:self];
        } else {
            @throw [NSException exceptionWithName:@"STKMenuControllerException"
                                           reason:@"All view controllers must be embedded in a UINavigationController"
                                         userInfo:nil];
        }
        
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        
    }
    [self setSelectedViewController:[viewControllers objectAtIndex:0]];
    
    if(_menuView) {
        [[self menuView] setItems:[viewControllers valueForKey:@"tabBarItem"]];
    }
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (void)loadView
{
    UIView *v = [[UIView alloc] init];
    [self setView:v];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [v addSubview:imageView];
    [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v]|"
                                                              options:0
                                                              metrics:nil
                                                                views:@{@"v" : imageView}]];
    [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|"
                                                              options:0
                                                              metrics:nil
                                                                views:@{@"v" : imageView}]];
    
    
    _backgroundImageView = imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[self viewControllers] count] > 0)
        [self setSelectedViewController:[[self viewControllers] objectAtIndex:0]];
    [[self menuView] setVisible:NO];
    [[self backgroundImageView] setImage:[self backgroundImage]];
}


@end
