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

@import QuartzCore;

@interface STKMenuController () <UINavigationControllerDelegate, STKMenuViewDelegate>

@property (nonatomic, strong) STKMenuView *menuView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation STKMenuController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        
    }
    return self;
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

        UIViewController *selected = [self selectedViewController];
        CGRect r = [[self menuView] frame];
        if([selected isKindOfClass:[UINavigationController class]]) {
            UINavigationBar *bar = [(UINavigationController *)selected navigationBar];
            CGRect barFrame = [bar frame];
            r.origin.y = barFrame.size.height + barFrame.origin.y;
            [[self menuView] setFrame:r];
        } else {
            r.origin.y = 0;
            [[self menuView] setFrame:r];
        }
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
        
        [[self menuView] setSelectedIndex:[[self viewControllers] indexOfObject:_selectedViewController]];
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
