//
//  STKAppDelegate.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKAppDelegate.h"
#import "STKMenuController.h"
#import "STKHomeViewController.h"
#import "STKExploreViewController.h"
#import "STKTrustViewController.h"
#import "STKProfileViewController.h"
#import "STKActivityViewController.h"
#import "STKGraphViewController.h"


@implementation STKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UIViewController *hvc = [[STKHomeViewController alloc] init];
    UIViewController *evc = [[STKExploreViewController alloc] init];
    UIViewController *tvc = [[STKTrustViewController alloc] init];
    UIViewController *pvc = [[STKProfileViewController alloc] init];
    UIViewController *avc = [[STKActivityViewController alloc] init];
    UIViewController *gvc = [[STKGraphViewController alloc] init];
    

    STKMenuController *nvc = [[STKMenuController alloc] init];
    [nvc setViewControllers:@[
        [[UINavigationController alloc] initWithRootViewController:hvc],
        [[UINavigationController alloc] initWithRootViewController:evc],
        [[UINavigationController alloc] initWithRootViewController:tvc],
        [[UINavigationController alloc] initWithRootViewController:pvc],
        [[UINavigationController alloc] initWithRootViewController:avc],
        [[UINavigationController alloc] initWithRootViewController:gvc]                              
    ]];
    [nvc setBackgroundImage:[UIImage imageNamed:@"PrismMainMenuBack.png"]];
    
    [[self window] setRootViewController:nvc];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
