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

@import QuartzCore;

static NSTimeInterval const STKMessageBannerDisplayDuration = 3.0;
static NSTimeInterval const STKMessageBannerAnimationDuration = .5;

static int HALikeNotificationCount = 0;
static int HAUserNotificationCount = 0;
static int HATrustNotificationCount = 0;
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
@property (nonatomic, strong) UIImageView *leftNotificationView;
@property (nonatomic, strong) UIImageView *centerNotificationView;
@property (nonatomic, strong) UIImageView *rightNotificationView;

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
    }
    
    return self;
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
    
    
    [self displayNotificationButtons:userInfo];

    [[self menuView] setNotificationCount:count];
}

- (void)displayNotificationButtons:(NSDictionary *)userInfo
{
    long trustCount = [[userInfo valueForKey:HAUserStoreActivityTrustKey] longValue];
    long likeCount = [[userInfo valueForKey:HAUserStoreActivityLikeKey] longValue];
    long userCount = [[userInfo valueForKey:HAUserStoreActivityUserKey] longValue];
    BOOL hasTrustNotifications = trustCount > HATrustNotificationCount;
    BOOL hasUserNotifications = userCount > HAUserNotificationCount;
    BOOL hasLikeNotifications = likeCount > HALikeNotificationCount;
    HATrustNotificationCount = (int)trustCount;
    HALikeNotificationCount = (int)likeCount;
    HAUserNotificationCount = (int)userCount;
    if (!HAActivityIsAnimating) {
        if (hasLikeNotifications) {
            [self.leftNotificationView setImage:[UIImage imageNamed:@"like_notification"]];
            if (hasUserNotifications) {
                [self.centerNotificationView setImage:[UIImage imageNamed:@"user_notification"]];
                if (hasTrustNotifications){
                    [self.rightNotificationView setImage:[UIImage imageNamed:@"trust_notification"]];
                } else {
                    [self.rightNotificationView setImage:nil];
                }
            } else if (hasTrustNotifications) {
                [self.centerNotificationView setImage:[UIImage imageNamed:@"trust_notification"]];
                [self.rightNotificationView setImage:nil];
            } else {
                [self.centerNotificationView setImage:nil];
                [self.rightNotificationView setImage:nil];
            }
        } else if (hasUserNotifications) {
            [self.leftNotificationView setImage:[UIImage imageNamed:@"user_notification"]];
            [self.rightNotificationView setImage:nil];
            if (hasTrustNotifications) {
                [self.centerNotificationView setImage:[UIImage imageNamed:@"trust_notification"]];
            } else {
                [self.centerNotificationView setImage:nil];
            }
        } else if (hasTrustNotifications){
            [self.leftNotificationView setImage:[UIImage imageNamed:@"trust_notification"]];
            [self.centerNotificationView setImage:nil];
            [self.rightNotificationView setImage:nil];
        } else {
            [self.leftNotificationView setImage:nil];
            [self.centerNotificationView setImage:nil];
            [self.rightNotificationView setImage:nil];
        }
        [self.view bringSubviewToFront:self.rightNotificationView];
        [self.view bringSubviewToFront:self.centerNotificationView];
        [self.view bringSubviewToFront:self.leftNotificationView];
        if ((hasLikeNotifications || hasTrustNotifications || hasUserNotifications )) {
            HAActivityIsAnimating = YES;
            [UIView animateWithDuration:1.0 animations:^{
                [self.centerNotificationView setAlpha:1];
                [self.leftNotificationView setAlpha:1];
                [self.rightNotificationView setAlpha:1];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:2.0 animations:^{
                    [self.centerNotificationView setAlpha:0];
                    [self.leftNotificationView setAlpha:0];
                    [self.rightNotificationView setAlpha:0];
                } completion:^(BOOL finished) {
                    HAActivityIsAnimating = NO;
                }];
            }];
            
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

    for(UIViewController *vc in viewControllers) {
        if([vc isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)vc setDelegate:self];
            [[(UINavigationController *)vc navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
            [[(UINavigationController *)vc navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName : STKTextColor,
                                                                                  NSFontAttributeName : STKFont(22)}];
            [[(UINavigationController *)vc navigationBar] setTintColor:[STKTextColor colorWithAlphaComponent:0.8]];
            [[(UINavigationController *)vc navigationBar] setTitleVerticalPositionAdjustment:4 forBarMetrics:UIBarMetricsDefault];
        } else {
            @throw [NSException exceptionWithName:@"STKMenuControllerException"
                                           reason:@"All view controllers must be embedded in a UINavigationController"
                                         userInfo:nil];
        }
        
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        
    }
    [self setSelectedViewController:[viewControllers objectAtIndex:0]];
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
    
    self.leftNotificationView = [[UIImageView alloc] initWithFrame:CGRectMake(45.f, 32.f, 28.f, 19.f)];
    self.centerNotificationView = [[UIImageView alloc] initWithFrame:CGRectMake(65.f, 32.f, 28.f, 19.f)];
    self.rightNotificationView = [[UIImageView alloc] initWithFrame:CGRectMake(85.f, 32.f, 28.f, 19.f)];
    [self.leftNotificationView setAlpha:0.f];
    [self.rightNotificationView setAlpha:0.f];
    [self.centerNotificationView setAlpha:0.f];
    [self.view addSubview:self.rightNotificationView];
    [self.view addSubview:self.centerNotificationView];
    [self.view addSubview:self.leftNotificationView];
    
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
    
    [[self transitionImageView] setImage:image];
    
    STKPostViewController *postVC = [[STKPostViewController alloc] init];
    [postVC setPost:p];
    [[vc navigationController] pushViewController:postVC animated:animated];
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
    return [[self transitionImageView] image];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if(([fromVC class] == [STKPostViewController class] && operation == UINavigationControllerOperationPop)
    || ([toVC class] == [STKPostViewController class] && operation == UINavigationControllerOperationPush)) {
        
        
        if([fromVC class] == [STKPostViewController class]) {
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
    if([inVC class] == [STKPostViewController class]) {
        [[inVC view] setAlpha:0];
        [[transitionContext containerView] addSubview:[inVC view]];
    } else {
        [[transitionContext containerView] insertSubview:[inVC view]
                                            belowSubview:[outVC view]];
    }
    
    [[self view] bringSubviewToFront:[self transitionImageView]];
    [[self transitionImageView] setHidden:NO];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        if([inVC class] == [STKPostViewController class]) {
            [[self transitionImageView] setFrame:CGRectMake(0, 111, 320, 300)];
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
