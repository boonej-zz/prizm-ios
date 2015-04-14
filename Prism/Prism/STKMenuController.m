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
#import "STKBaseStore.h"
#import "STKPostViewController.h"
#import "STKImageStore.h"
#import "STKResolvingImageView.h"
#import "STKPost.h"
#import "STKMessageBanner.h"
#import "STKUserStore.h"
#import "HAFastSwitchViewController.h"
#import "HAInterestsViewController.h"
#import "STKInsightTarget.h"
#import "HAInsightsViewController.h"
#import "UIERealTimeBlurView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "HAWelcomeViewController.h"
#import "STKOrganization.h"
#import "STKUser.h"
#import "STKOrgStatus.h"

@import QuartzCore;

static NSTimeInterval const STKMessageBannerDisplayDuration = 3.0;
static NSTimeInterval const STKMessageBannerAnimationDuration = .5;

static int HALikeNotificationCount = 0;
static int HAUserNotificationCount = 0;
static int HATrustNotificationCount = 0;
static int HACommentNotificationCount = 0;
static int HAInsightNotificationCount = 0;
static BOOL HAActivityIsAnimating = NO;

@interface STKMenuController () <UINavigationControllerDelegate, STKMenuViewDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) STKMenuView *menuView;
@property (nonatomic, strong) STKMessageBanner *messageBanner;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) NSLayoutConstraint *menuTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *messageBannerTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *messageBannerHeightConstraint;
@property (nonatomic, strong) NSTimer *messageBannerDuration;
//@property (nonatomic, strong) HANotificationViewController *nvc;
@property (nonatomic, strong) UIImageView *notificationView1;
@property (nonatomic, strong) UIImageView *notificationView2;
@property (nonatomic, strong) UIImageView *notificationView3;
@property (nonatomic, strong) UIImageView *notificationView4;
@property (nonatomic, strong) UIImageView *notificationView5;
@property (nonatomic) UINavigationControllerOperation operation;
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, strong, readonly) UIImageView *transitionImageView;
@property (nonatomic) CGRect imageTransitionRect;

@end

@implementation STKMenuController
@synthesize transitionImageView = _transitionImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userBecameUnauthorized:)
                                                     name:STKSessionEndedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveNetworkError:)
                                                     name:@"STKConnectionNetworkError"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:HANotificationKeyUserLoggedOut object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivities:) name:@"ShowActivities" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWelcome:) name:@"ShowWelcome" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated:) name:@"UserDetailsUpdated" object:nil];
    }
    
    return self;
}

- (void)showWelcome:(STKOrgStatus *)status
{
    STKUser *user = [[STKUserStore store] currentUser];
    [[STKUserStore store] fetchOrganizationByCode:user.programCode completion:^(STKOrganization *organization, NSError *err) {
        if (organization){
            user.organization = organization;
            HAWelcomeViewController *wvc = [[HAWelcomeViewController alloc] init];
            [wvc setOrganization:user.organization];
            [wvc setTitle:@"Welcome to"];
            [[self navigationController] pushViewController:wvc animated:NO];
            STKVerticalNavigationController *nvc = [[STKVerticalNavigationController alloc] initWithRootViewController:wvc];
            [self presentViewController:nvc animated:YES
                             completion:nil];
        }
    }];
}

- (void)profileUpdated:(NSNotification *)note
{
    STKUser *cu = [[STKUserStore store] currentUser];
    NSSet *matched = [cu.organizations filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"status = %@", @"active"]];
    if (matched.count > 0) {
        if (![[NSUserDefaults standardUserDefaults] valueForKey:@"DidShowWelcomeScreen"]) {
            [self showWelcome:[matched allObjects][0]];
        }
    }
}

- (void)showActivities:(NSNotification *)note
{
    [self setSelectedViewController:[self.viewControllers objectAtIndex:4]];
}

- (void)userLoggedOut:(id)sender
{
    [self recreateAllViewControllers];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)didReceiveNetworkError:(NSNotification *)note
{
    [self displayBannerWithMessage:@"Network Offline"
                           forType:STKMessageBannerTypeError];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)userBecameUnauthorized:(NSNotification *)note
{
    if ([[STKUserStore store] loggedInUsers].count == 0) {
        [[STKUserStore store] setCurrentUser:nil];
        if([[self presentedViewController] isKindOfClass:[STKVerticalNavigationController class]]) {
            return;
        }
        
        NSString *reasonValue = [[note userInfo] objectForKey:STKSessionEndedReasonKey];
        NSString *msg = nil;
        if([reasonValue isEqualToString:STKSessionEndedConnectionValue]) {
            msg = NSLocalizedString(@"Oops. There was an issue with your connection and you could not be authenticated with the server. Please make sure you have an internet connection and log in again.", @"session ended connection message");
        } else if ([reasonValue isEqualToString:STKSessionEndedAuthenticationValue]) {
            msg = NSLocalizedString(@"Your session has ended. Please try to login again.", @"session ended, try again message");
        }
        
        // Only if we need a message do we show the alert view
        UIAlertView *av = nil;
        if(msg) {
            av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Session Ended", "session ended title")
                                            message:msg
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                  otherButtonTitles:nil];
        }
        
        [self recreateAllViewControllers];
        
        void (^presentRegistration)(void) = ^{
            STKRegisterViewController *rvc = [[STKRegisterViewController alloc] init];
            STKVerticalNavigationController *nvc = [[STKVerticalNavigationController alloc] initWithRootViewController:rvc];
            [self presentViewController:nvc animated:YES
                             completion:^{
                                 
                                 [av show];
                             }];
        };
        
        if([self presentedViewController]) {
            [self dismissViewControllerAnimated:YES completion:presentRegistration];
        } else {
            presentRegistration();
        }
    }
    
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
        [[self menuView] setItems:[[self viewControllers] valueForKey:@"tabBarItem"]];
        
        [[self view] bringSubviewToFront:[self menuView]];

        CGRect blurRect = [[self view] bounds];
        
        UIViewController *selected = [self selectedViewController];
        [selected menuWillAppear:animated];
        
        float topOffset = [self navBarOffset];
        
        if(topOffset > 0) {
            blurRect.origin.y += topOffset;
            blurRect.size.height -= topOffset;
        }
        
        [[self menuTopConstraint] setConstant:topOffset];
        
        UIImage *bgImage = [[STKRenderServer renderServer] instantBlurredImageForView:[self view]
                                                                            inSubrect:blurRect];
        
        [[self menuView] setBackgroundImage:bgImage];
        [[self menuView] layoutIfNeeded];
        
    } else {
        [[self selectedViewController] menuWillDisappear:animated];
    }
    [[self menuView] setVisible:menuVisible animated:animated];
}

- (BOOL)isMenuVisible
{
    return [[self menuView] isVisible];
}

- (CGFloat)navBarOffset
{
    if([[self selectedViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationBar *bar = [(UINavigationController *)[self selectedViewController] navigationBar];
        CGRect frame = [bar frame];
        return frame.origin.y + frame.size.height;
    }
    return 0;
}

- (STKMenuView *)menuView
{
    [self loadMenuIfRequired];
    return _menuView;
}

- (STKMessageBanner *)messageBanner
{
    [self loadMessageBannerIfRequired];
    return _messageBanner;
}

- (void)displayBannerWithMessage:(NSString *)message forType:(STKMessageBannerType)type
{
    if(![[self messageBanner] isVisible]) {
        [[self messageBanner] setLabelText:message];
        [[self messageBanner] setType:type];
        [self displayMessageBanner];
    }
    
    [[self messageBannerDuration] invalidate];
    [self setMessageBannerDuration:[NSTimer scheduledTimerWithTimeInterval:STKMessageBannerDisplayDuration
                                                                    target:self
                                                                  selector:@selector(dismissMessageBanner)
                                                                  userInfo:nil
                                                                   repeats:NO]];
}

- (void)displayMessageBanner
{
    if([[STKUserStore store] currentUser]) {
        [[self view] bringSubviewToFront:[self messageBanner]];
        [UIView animateWithDuration:.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [[self messageBanner] setVisible:YES];
                             [[self messageBanner] layoutIfNeeded];
                             [[self messageBannerHeightConstraint] setConstant:STKMessageBannerHeight];
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (void)dismissMessageBanner
{
    [UIView animateWithDuration:STKMessageBannerAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [[self messageBanner] layoutIfNeeded];
                         [[self messageBannerHeightConstraint] setConstant:0];
                     } completion:^(BOOL finished) {
                         if(finished) {
                             [[self messageBanner] setVisible:NO];
                         }
                     }];
}

- (void)menuView:(STKMenuView *)menuView didSelectItemAtIndex:(int)idx
{
    // Ensure that this line of code is always sent before the changing of the selected view controller
    [self setMenuVisible:NO animated:YES];
    
    UIViewController *vc = [[self viewControllers] objectAtIndex:idx];
    if(vc != [self selectedViewController])
        [self setSelectedViewController:vc];
    else {
        [(UINavigationController *)[self selectedViewController] popToRootViewControllerAnimated:NO];
    }
    
    if([[self messageBanner] isVisible]) {
        [[self view] bringSubviewToFront:[self messageBanner]];
    }
}

- (void)menuView:(STKMenuView *)menuView didLongPressItemAtIndex:(int)idx
{
    if (idx == 3) {
        [self showFastSwitchMenu:nil];
    }
}

- (void)showFastSwitchMenu:(id)sender
{
    [self setMenuVisible:NO animated:YES];
//    STKMenuController *rvc = (STKMenuController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    HAFastSwitchViewController *fsvc = [[HAFastSwitchViewController alloc] init];
    if ([[self selectedViewController] isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self.selectedViewController pushViewController:fsvc animated:NO];
    }
    
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [[[self selectedViewController] view] removeFromSuperview];
    
    _selectedViewController = selectedViewController;
    [(UINavigationController *)_selectedViewController popToRootViewControllerAnimated:NO];
    
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

- (void)loadMessageBannerIfRequired
{
    if(_messageBanner)
        return;
    
    [self setMessageBanner:[[STKMessageBanner alloc] init]];
    [[self view] addSubview:[self messageBanner]];
    
    CGFloat bannerOffSet = -([self navBarOffset]);
    NSLayoutConstraint *bannerTop = [NSLayoutConstraint constraintWithItem:[self view]
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:[self messageBanner]
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:bannerOffSet];
    
    NSLayoutConstraint *bannerHeight = [NSLayoutConstraint constraintWithItem:[self messageBanner]
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:0];
    
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:[self view]
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:[self messageBanner]
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1
                                                             constant:0]];
    
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:[self view]
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:[self messageBanner]
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1
                                                             constant:0]];


    [[self view] addConstraint:bannerTop];
    [[self messageBanner] addConstraint:bannerHeight];
    [self setMessageBannerTopConstraint:bannerTop];
    [self setMessageBannerHeightConstraint:bannerHeight];
    [[self messageBanner] layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationUpdate:)
                                                 name:STKUserStoreActivityUpdateNotification
                                               object:nil];
}

- (void)notificationUpdate:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    int count = [[[note userInfo] objectForKey:STKUserStoreActivityUpdateCountKey] intValue];
    if ([[STKUserStore store] currentUser]) {
        [[STKUserStore store] fetchUserDetails:[[STKUserStore store] currentUser] additionalFields:@[] completion:^(STKUser *u, NSError *err) {
            NSLog(@"Refreshed user");
        }];
    }
    
    [self displayNotificationButtons:userInfo];

    [[self menuView] setNotificationCount:count];
}

- (void)displayNotificationButtons:(NSDictionary *)userInfo
{
    long trustCount = [[userInfo valueForKey:HAUserStoreActivityTrustKey] longValue];
    long likeCount = [[userInfo valueForKey:HAUserStoreActivityLikeKey] longValue];
    long userCount = [[userInfo valueForKey:HAUserStoreActivityUserKey] longValue] + [[userInfo valueForKey:HAUserStoreActivityLuminaryPostKey] longValue];
    long commentCount = [[userInfo valueForKey:HAUserStoreActivityCommentKey] longValue];
    long insightCount = [[userInfo valueForKey:HAUserStoreActivityInsightKey] longValue];
    BOOL hasTrustNotifications = trustCount > HATrustNotificationCount;
    BOOL hasUserNotifications = userCount > HAUserNotificationCount;
    BOOL hasLikeNotifications = likeCount > HALikeNotificationCount;
    BOOL hasCommentNotification = commentCount > HACommentNotificationCount;
    BOOL hasInsightNotification = insightCount > HAInsightNotificationCount;
    
//    
//    BOOL hasTrustNotifications = YES;
//    BOOL hasUserNotifications = NO;
//    BOOL hasLikeNotifications = YES;
//    BOOL hasCommentNotification = YES;
    
    HATrustNotificationCount = (int)trustCount;
    HALikeNotificationCount = (int)likeCount;
    HAUserNotificationCount = (int)userCount;
    HACommentNotificationCount = (int)commentCount;
    HAInsightNotificationCount = (int)insightCount;
    
    UIImage *likeImage = [UIImage imageNamed:@"like_notification"];
    UIImage *userImage = [UIImage imageNamed:@"user_notification"];
    UIImage *trustImage = [UIImage imageNamed:@"trust_notification"];
    UIImage *commentImage = [UIImage imageNamed:@"comment_notification"];
    UIImage *insightImage = [UIImage imageNamed:@"insight_notification"];
                           
    
    if (!HAActivityIsAnimating) {
        HAActivityIsAnimating = YES;
        [self.notificationView1 setImage:nil];
        [self.notificationView2 setImage:nil];
        [self.notificationView3 setImage:nil];
        [self.notificationView4 setImage:nil];
        [self.notificationView5 setImage:nil];
        // Like Notifications
        if (hasLikeNotifications) {
            [self.notificationView1 setImage:likeImage];
            if (hasUserNotifications) {
                [self.notificationView2 setImage:userImage];
                if (hasTrustNotifications){
                    [self.notificationView3 setImage:trustImage];
                    if (hasCommentNotification) {
                        [self.notificationView4 setImage:commentImage];
                        if (hasInsightNotification) {
                            [self.notificationView5 setImage:insightImage];
                        }
                    } else if (hasInsightNotification){
                        [self.notificationView4 setImage:insightImage];
                    }
                } else if (hasCommentNotification) {
                    [self.notificationView3 setImage:commentImage];
                    if (hasInsightNotification) {
                        [self.notificationView4 setImage:insightImage];
                    }
                }
            } else if (hasTrustNotifications) {
                [self.notificationView2 setImage:trustImage];
                if (hasCommentNotification) {
                    [self.notificationView3 setImage:commentImage];
                    if (hasInsightNotification) {
                        [self.notificationView4 setImage:insightImage];
                    }
                } else {
                    if (hasInsightNotification) {
                        [self.notificationView3 setImage:insightImage];
                    }
                }
            } else if (hasCommentNotification) {
                [self.notificationView2 setImage:commentImage];
                if (hasInsightNotification) {
                    [self.notificationView3 setImage:insightImage];
                }
            } else if (hasInsightNotification) {
                [self.notificationView2 setImage:insightImage];
                
            }
        } else if (hasUserNotifications) {
            [self.notificationView1 setImage:userImage];
            if (hasTrustNotifications) {
                [self.notificationView2 setImage:trustImage];
                if (hasCommentNotification) {
                    [self.notificationView3 setImage:commentImage];
                    if (hasInsightNotification) {
                        [self.notificationView4 setImage:insightImage];
                    }
                } else if (hasInsightNotification) {
                    [self.notificationView3 setImage:insightImage];
                }
            } else {
                if (hasCommentNotification) {
                    [self.notificationView2 setImage:commentImage];
                    if (hasInsightNotification){
                        [self.notificationView3 setImage:insightImage];
                    }
                } else if (hasInsightNotification) {
                    [self.notificationView2 setImage:insightImage];
                }
            }
        } else if (hasTrustNotifications) {
            [self.notificationView1 setImage:trustImage];
            if (hasCommentNotification) {
                [self.notificationView2 setImage:commentImage];
                if (hasInsightNotification) {
                    [self.notificationView3 setImage:insightImage];
                }
            } else if (hasInsightNotification) {
                [self.notificationView2 setImage:insightImage];
            }
        } else if (hasCommentNotification) {
            [self.notificationView1 setImage:commentImage];
            if (hasInsightNotification) {
                [self.notificationView2 setImage:insightImage];
            }
        } else if (hasInsightNotification){
            [self.notificationView1 setImage:insightImage];
        }

        [self.view bringSubviewToFront:self.notificationView5];
        [self.view bringSubviewToFront:self.notificationView4];
        [self.view bringSubviewToFront:self.notificationView3];
        [self.view bringSubviewToFront:self.notificationView2];
        [self.view bringSubviewToFront:self.notificationView1];
        if ((hasLikeNotifications || hasTrustNotifications || hasUserNotifications || hasCommentNotification || hasInsightNotification)) {
            
            [UIView animateWithDuration:1.0 animations:^{
                [self.notificationView1 setAlpha:1];
                [self.notificationView2 setAlpha:1];
                [self.notificationView3 setAlpha:1];
                [self.notificationView4 setAlpha:1];
                [self.notificationView5 setAlpha:1];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:2.0 animations:^{
                        [self.notificationView1 setAlpha:0];
                        [self.notificationView2 setAlpha:0];
                        [self.notificationView3 setAlpha:0];
                        [self.notificationView4 setAlpha:0];
                        [self.notificationView5 setAlpha:0];
                    } completion:^(BOOL finished) {
                        HAActivityIsAnimating = NO;
                    }];
                });
            }];
            
        } else {
            HAActivityIsAnimating = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)toggleMenu:(id)sender
{
    [self setMenuVisible:![self isMenuVisible] animated:YES];
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
    [self refreshNavBars];
    for(UIViewController *vc in viewControllers) {
        
        
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        
    }
    [self setSelectedViewController:[viewControllers objectAtIndex:0]];
}

- (void)refreshNavBars
{
    for (UIViewController *vc in self.viewControllers) {
        if([vc isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)vc setDelegate:self];
            [[(UINavigationController *)vc navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
            [[(UINavigationController *)vc navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor HATextColor],
                                                                                   NSFontAttributeName : STKFont(22)}];
            [[(UINavigationController *)vc navigationBar] setTintColor:[[UIColor HATextColor] colorWithAlphaComponent:0.8]];
            [[(UINavigationController *)vc navigationBar] setTitleVerticalPositionAdjustment:4 forBarMetrics:UIBarMetricsDefault];
        } else {
            @throw [NSException exceptionWithName:@"STKMenuControllerException"
                                           reason:@"All view controllers must be embedded in a UINavigationController"
                                         userInfo:nil];
        }
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
    
    self.notificationView1 = [[UIImageView alloc] initWithFrame:CGRectMake(45.f, 32.f, 28.f, 19.f)];
    self.notificationView2 = [[UIImageView alloc] initWithFrame:CGRectMake(65.f, 32.f, 28.f, 19.f)];
    self.notificationView3 = [[UIImageView alloc] initWithFrame:CGRectMake(85.f, 32.f, 28.f, 19.f)];
    self.notificationView4 = [[UIImageView alloc] initWithFrame:CGRectMake(105.f, 32.f, 28.f, 19.f)];
    self.notificationView5 = [[UIImageView alloc] initWithFrame:CGRectMake(125.f, 32.f, 28.f, 19.f)];
    
    [self.notificationView1 setAlpha:0.f];
    [self.notificationView3 setAlpha:0.f];
    [self.notificationView2 setAlpha:0.f];
    [self.notificationView4 setAlpha:0.f];
    [self.notificationView5 setAlpha:0.f];
    
    [self.view addSubview:self.notificationView1];
    [self.view addSubview:self.notificationView2];
    [self.view addSubview:self.notificationView3];
    [self.view addSubview:self.notificationView4];
    [self.view addSubview:self.notificationView5];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUserRegistered:) name:@"didRegisterNewAccount" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fishBlurView) name:@"FinishedActivity" object:nil];
//
//    [[UINavigationBar appearanceWhenContainedIn:[UIActivityViewController class], nil] setTranslucent:NO];
    
    [[UITextField appearanceWhenContainedIn:[UIActivityViewController class], nil] setTintColor:nil];
    [[UITextView appearanceWhenContainedIn:[UIActivityViewController class], nil] setTintColor:nil];
//    [[UINavigationBar appearanceWhenContainedIn:[UIDocumentInteractionController class], nil] setTranslucent:NO];
//    
//    [[UITextField appearanceWhenContainedIn:[UIDocumentInteractionController class], nil] setTintColor:nil];
//    [[UITextView appearanceWhenContainedIn:[UIDocumentInteractionController class], nil] setTintColor:nil];
    
}

- (void)fishBlurView
{
//    [[UINavigationBar appearance] setBarTintColor:nil];
    
//    UIViewController *vc = [self selectedViewController];
//    if ([vc isKindOfClass:[UINavigationController class]]) {
//        [vc = [(UINavigationController *)vc viewControllers]]
//    }
//    for (UIView *v in  vc.view.subviews) {
//        NSString *str = [NSString stringWithFormat:@"%@", [v class]];
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Her" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        if (v.tag == 99999) {
//            [vc.view bringSubviewToFront:v];
//        }
//    }
}

- (void)newUserRegistered:(NSNotification *)note
{
    HAInterestsViewController *ivc = [[HAInterestsViewController alloc] init];
    STKUser *user = [[note userInfo] objectForKey:@"user"];
    [ivc setUser:user];
    [self.navigationController pushViewController:ivc animated:NO];
}

- (UIViewController *)childViewControllerForType:(Class)cls
{
    NSLog(@"%@", cls);
    for(UINavigationController *vc in [self viewControllers]) {
        NSLog(@"%@ == %@", [vc class], cls);
        if([[[vc viewControllers] firstObject] isKindOfClass:cls]) {
            return vc;
        }
    }
    return nil;
}

- (UIImageView *)transitionImageView
{
    if(!_transitionImageView) {
        _transitionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
        [[self view] addSubview:_transitionImageView];
    }
    
    return _transitionImageView;
}

- (void)transitionToPost:(STKPost *)p
                fromRect:(CGRect)r
              usingImage:(UIImage *)image
        inViewController:(UIViewController *)vc
                animated:(BOOL)animated
{
    [self setImageTransitionRect:r];
    
    UIImage *newImage;
    if (image.size.width < 600 && image.size.width > 0) {
        CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, 0);
        CGContextDrawImage(context, imageRect, [image CGImage]);
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        newImage = [UIImage imageWithCGImage:imageRef];
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CFRelease(imageRef);
    } else {
        newImage = image;
    }
    self.originalImage = image;
    NSLog(@"%f", image.size.width);
    if (image == nil) {
        image = [p largeTypeImage];
        
    }
    [[self transitionImageView] setImage:newImage];
    
    STKPostViewController *postVC = [[STKPostViewController alloc] init];
    [postVC setPost:p];
    [[vc navigationController] pushViewController:postVC animated:animated];
}

- (void)transitionToInsightTarget:(STKInsightTarget *)it
                fromRect:(CGRect)r
              usingImage:(UIImage *)image
        inViewController:(UIViewController *)vc
                animated:(BOOL)animated
{
    [self setImageTransitionRect:r];
    
    [[self transitionImageView] setImage:image];
    
    HAInsightsViewController *ivc = [[HAInsightsViewController alloc] init];
    [ivc setInsightTarget:it];
    [ivc setModal:YES];
    [[vc navigationController] pushViewController:ivc animated:animated];
}

- (void)transitionToCreatePostWithImage:(UIImage *)image
{
    
    void (^createPost)(void) = ^{
        STKCreatePostViewController *cpvc = [[STKCreatePostViewController alloc] init];
        [cpvc setPostImage:image];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cpvc];
        [[self selectedViewController] presentViewController:nvc animated:YES completion:nil];
    };
    
    if([[self selectedViewController] presentedViewController]){
        [[[self selectedViewController] presentedViewController] dismissViewControllerAnimated:NO completion:^{
            createPost();
        }];
    } else {
        createPost();
    }
}


- (UIImage *)transitioningImage
{
    UIImage *image = self.transitionImageView.image ;
    
    return image;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    self.operation = operation;
    if (([fromVC class] == [HAInsightsViewController class] || [fromVC class] == [STKActivityViewController class])&& ([toVC class] == [HAInsightsViewController class] || [toVC isKindOfClass:[STKActivityViewController class]])) {
        if ([fromVC isKindOfClass:[HAInsightsViewController class]]) {
            HAInsightsViewController *hvc = (HAInsightsViewController *)fromVC;
            if ([hvc.segmentedControl selectedSegmentIndex] == 0 && ! [hvc isArchived] && [toVC class] != [STKProfileViewController class]) {
                if (operation == UINavigationControllerOperationPush) {
                    [[self transitionImageView] setFrame:self.imageTransitionRect];
                } else {
                    [[self transitionImageView] setFrame:CGRectMake(0, 116, 320, 300)];
                }
                return  self;
            } else {
                return nil;
            }
        } else {
            if (operation == UINavigationControllerOperationPush) {
                [[self transitionImageView] setFrame:self.imageTransitionRect];
            } else {
                [[self transitionImageView] setFrame:CGRectMake(0, 116, 320, 300)];
            }
            return self;
        }
    }
    if(([fromVC class] == [STKPostViewController class]&& operation == UINavigationControllerOperationPop)
    || ([toVC class] == [STKPostViewController class] && operation == UINavigationControllerOperationPush)) {
        
        
        if([fromVC class] == [STKPostViewController class] || ([fromVC class] == [HAInsightsViewController class] && operation == UINavigationControllerOperationPop)) {
            [self.transitionImageView setImage:self.originalImage];
            [[self transitionImageView] setFrame:CGRectMake(0, 111, 320, 300)];
        } else {
            [[self transitionImageView] setFrame:[self imageTransitionRect]];
        }
        
        return self;
    }
    
    return nil;
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    
    UIViewController *inVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *outVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([inVC isKindOfClass:[STKHomeViewController class]]) {
//        STKHomeViewController *hvc = (STKHomeViewController *)inVC;
//        [hvc.blurView setRenderStatic:YES];
        
    }
    CGRect transitionFrame;
    if ([inVC class] == [HAInsightsViewController class]) {
        transitionFrame = CGRectMake(0, 116, 320, 300);
    } else {
        transitionFrame = CGRectMake(0, 111, 320, 300);
    }
    
    if([inVC class] == [STKPostViewController class] || ([inVC class] == [HAInsightsViewController class] && self.operation == UINavigationControllerOperationPush)) {
        [[inVC view] setAlpha:0];
        [[transitionContext containerView] addSubview:[inVC view]];
    } else {
        [[transitionContext containerView] insertSubview:[inVC view]
                                            belowSubview:[outVC view]];
    }
    
    [[self view] bringSubviewToFront:[self transitionImageView]];
    [[self transitionImageView] setHidden:NO];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        if([inVC class] == [STKPostViewController class] || ([inVC class] == [HAInsightsViewController class] && self.operation == UINavigationControllerOperationPush)) {
            [[self transitionImageView] setFrame:transitionFrame];
            [[inVC view] setAlpha:1];
        } else {
            [[self transitionImageView] setFrame:[self imageTransitionRect]];
            [[outVC view] setAlpha:0];
        }
    }
     completion:^(BOOL finished) {
         [transitionContext completeTransition:finished];
         if(finished) {
             [[self transitionImageView] setHidden:YES];
         }
     }];
}




- (void)animationEnded:(BOOL) transitionCompleted
{
    
}

@end
