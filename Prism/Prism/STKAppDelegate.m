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
#import "STKRegisterViewController.h"
#import "STKVerticalNavigationController.h"
#import "STKUserStore.h"
#import "STKBaseStore.h"
#import "UIViewController+STKControllerItems.h"
#import "STKPostViewController.h"
#import "HAInsightsViewController.h"
#import <MessageUI/MessageUI.h>

#import <GooglePlus/GooglePlus.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Mixpanel.h"
#import "STKContentStore.h"
#import "HAInsightsViewController.h"
#import "STKAuthorizationToken.h"
#import "STKCreatePostViewController.h"
#import "HANavigationController.h"
#import "HAMessageViewController.h"
#import "HACalendarViewController.h"
#import "HASurveyViewController.h"
#import "Heap.h"
#import "HAConsentViewController.h"
//#import "TMAPIClient.h"

#ifdef DEBUG 
    static NSString * const STKMixpanelKey = @"";//@"73c8b5e42732b21ff8b74d73aabc8f79";
#else
//    static NSString * const STKMixpanelKey = @"4a0537b6af3aacf933fa10bc70050237";
    static NSString * const STKMixpanelKey = @"831cd11c7aedb1175765d2a9583c5cff";
#endif

@interface STKAppDelegate ()

@end

@implementation STKAppDelegate 

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSLog(@"%@", deviceToken);
    [[STKUserStore store] updateDeviceTokenForCurrentUser:deviceToken];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [Fabric with:@[CrashlyticsKit]];
#ifdef DEBUG
    [Heap setAppId:@"3468470936"];
#else
    [Heap setAppId:@"3662545250"];
#endif
    
#ifdef HEAP
    [Heap enableVisualizer];
#endif

    
    /* Other launch code goes here */
    
    [Mixpanel sharedInstanceWithToken:STKMixpanelKey];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [[STKUserStore store] syncInterests];
    [self configureAppearanceProxies];
    
    STKUser *u = [[STKUserStore store] currentUser];
    
    UIViewController *hvc = [[STKHomeViewController alloc] init];
    UIViewController *evc = [[STKExploreViewController alloc] init];
//    UIViewController *tvc = [[STKTrustViewController alloc] init];
    UIViewController *ivc = [[HAInsightsViewController alloc] init];
    UIViewController *pvc = [[STKProfileViewController alloc] init];
    UIViewController *avc = [[STKActivityViewController alloc] init];
    UIViewController *gvc = [[STKGraphViewController alloc] init];
    UIViewController *mvc = [[HAMessageViewController alloc] init];
    UIViewController *cal = [[HACalendarViewController alloc] init];
    UIViewController *sur = [[HASurveyViewController alloc] init];
//    UIViewController *ivc = [[HAInsightsViewController alloc] init];
    



    STKMenuController *nvc = [[STKMenuController alloc] init];
    [nvc setViewControllers:@[
        [[UINavigationController alloc] initWithRootViewController:hvc],
        [[UINavigationController alloc] initWithRootViewController:evc],
//        [[UINavigationController alloc] initWithRootViewController:tvc],
        [[UINavigationController alloc] initWithRootViewController:ivc],
        [[UINavigationController alloc] initWithRootViewController:pvc],
        [[UINavigationController alloc] initWithRootViewController:avc],
        [[UINavigationController alloc] initWithRootViewController:gvc],
        [[UINavigationController alloc] initWithRootViewController:mvc],
        [[UINavigationController alloc] initWithRootViewController:cal],
        [[UINavigationController alloc] initWithRootViewController:sur]
    ]];
    [nvc setBackgroundImage:[UIImage HABackgroundImage]];
    
    for(UINavigationController *vc in [nvc viewControllers]) {
        [[vc navigationBar] setTranslucent:YES];
    }    
    
    [[self window] setRootViewController:nvc];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if(!u) {
        STKRegisterViewController *rvc = [[STKRegisterViewController alloc] init];
        STKVerticalNavigationController *registerNVC = [[STKVerticalNavigationController alloc] initWithRootViewController:rvc];
//        HAConsentViewController *cvc = [[HAConsentViewController alloc] init];
//        STKVerticalNavigationController *rnvc = [[STKVerticalNavigationController alloc] initWithRootViewController:cvc];
//        [nvc presentViewController:rnvc animated:NO completion:nil];
        
        [nvc presentViewController:registerNVC animated:NO completion:nil];
    }
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowActivities" object:nil];
    }
    
    return YES;
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    NSLog(@"%@", userInfo);
    NSString *alertValue = [[userInfo valueForKeyPath:@"aps"] valueForKey:@"badge"];
    int badgeValue= [alertValue intValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeValue];
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    [[STKUserStore store] transferPostsFromSocialNetworks];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[Mixpanel sharedInstance] startSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[Mixpanel sharedInstance] endSession];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([[url scheme] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]){
/*        NSString *path = [url absoluteString];
        if ([path rangeOfString:@"tumblr"].location) {
            [[TMAPIClient sharedInstance] handleOpenURL:url];
        } else {
            [[GPPSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
        }*/

        [[GPPSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
        return YES;
    } else if ([[url scheme] isEqualToString:@"prizmapp"]) {
        NSString *task = [url query];
        if (task) {
            NSArray *taskArray = [task componentsSeparatedByString:@"="];
            if (taskArray.count == 2) {
                if ([taskArray[0] isEqualToString:@"post_id"]) {
                    [[STKContentStore store] fetchPostWithUniqueId:taskArray[1] completion:^(STKPost *p, NSError *err) {
                        if (!err) {
                            STKPostViewController *pvc = [[STKPostViewController alloc] init];
                            if ([p isKindOfClass:[NSArray class]]){
                                p = ((NSArray *)p)[0] ;
                            }
    
                            [pvc setPost:p];
                            
                            STKMenuController *rvc = (STKMenuController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
//                            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
//                            [[nvc navigationBar] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                            if (rvc.selectedViewController && [rvc.selectedViewController isKindOfClass:[UINavigationController class]]){
                                [(UINavigationController *)rvc.selectedViewController pushViewController:pvc animated:NO];
                            }
                        }
                    }];
                } else if ([taskArray[0] isEqualToString:@"insight_id"]) {
                    [[Mixpanel sharedInstance] track:@"Insight Opened from Email"];
                    HAInsightsViewController *ivc = [[HAInsightsViewController alloc] init];
                    STKMenuController *rvc = (STKMenuController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                    if (rvc.selectedViewController && [rvc.selectedViewController isKindOfClass:[UINavigationController class]]){
                        [(UINavigationController *)rvc.selectedViewController pushViewController:ivc animated:NO];
                    }
                }
            }
        }
    }
    
    UIImage *passedUrlImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    if(passedUrlImage){
        STKMenuController *menuController = (STKMenuController *)[[self window] rootViewController];
        [menuController transitionToCreatePostWithImage:passedUrlImage];
    }

    return YES;
}


- (void)configureAppearanceProxies
{
    UIImage *img;
    UIGraphicsBeginImageContext(CGSizeMake(10, 10));
    [[UIColor colorWithWhite:1 alpha:0.2] set];
    UIRectFill(CGRectMake(0, 0, 10, 10));
    img = UIGraphicsGetImageFromCurrentImageContext();
    

    UIGraphicsEndImageContext();
    
//    [[UINavigationBar appearance] setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearanceWhenContainedIn:[STKMenuController class], nil] setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[HANavigationController class], nil] setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
 
    [[UITextField appearanceWhenContainedIn:[UISearchBar class],nil] setFont:STKFont(14)];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    [[UITextView appearance] setTintColor:[UIColor whiteColor]];
}

@end
