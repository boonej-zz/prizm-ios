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

@implementation UIViewController (STKMenuControllerExtensions)

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

- (UIBarButtonItem *)postBarButtonItem
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [view addTarget:self action:@selector(createNewPost:) forControlEvents:UIControlEventTouchUpInside];
    [view setImage:[UIImage imageNamed:@"Add Content.png"] forState:UIControlStateNormal];
    [view setImage:[UIImage imageNamed:@"Add Contentpress.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    return bbi;
}

- (UIBarButtonItem *)menuBarButtonItem
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [view addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
    [view setImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
    [view setImage:[UIImage imageNamed:@"MenuPress.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
    return bbi;
}


- (void)createNewPost:(id)sender
{
    STKCreatePostViewController *cpc = [[STKCreatePostViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cpc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)toggleMenu:(id)sender
{
    STKMenuController *tbc = (STKMenuController *)[self menuController];
    [tbc setMenuVisible:![tbc isMenuVisible] animated:YES];
}

@end
