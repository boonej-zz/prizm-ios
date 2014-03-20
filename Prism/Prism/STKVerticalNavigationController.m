//
//  STKVerticalNavigationController.m
//  Prism
//
//  Created by Joe Conway on 12/5/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKVerticalNavigationController.h"

@interface STKVerticalNavigationController () <UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) UINavigationController *internalNavigationController;
@property (nonatomic, strong) UIControl *backButton;
@property (nonatomic, strong) UIImageView *backButtonImageView;
@property (nonatomic, strong) UIView *barContainer;
@property (nonatomic) UINavigationControllerOperation transitionOperation;


@end

@implementation STKVerticalNavigationController

- (id)initWithRootViewController:(UIViewController *)vc
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _internalNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [_internalNavigationController setDelegate:self];
        [_internalNavigationController setNavigationBarHidden:YES];
        [self addChildViewController:_internalNavigationController];
        [_internalNavigationController didMoveToParentViewController:self];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithRootViewController:nil];
}

- (void)pushViewController:(UIViewController *)vc forSender:(UIView *)sender
{/*
    CGRect r = [[self containerView] convertRect:[sender frame]
                                        fromView:[[self navigationController] view]];
    
    UIGraphicsBeginImageContext(r.size);
    [sender drawViewHierarchyInRect:CGRectMake(0, 0, r.size.width, r.size.height)
                 afterScreenUpdates:NO];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[self backButtonImageView] setImage:img];
    [[self backButton] setHidden:NO];*/
    
    [[self navigationController] pushViewController:vc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r = [[self view] bounds];
    _barContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, 86)];
    [_barContainer setBackgroundColor:[UIColor clearColor]];
    
    [[self containerView] addSubview:[[self internalNavigationController] view]];
    [[[self internalNavigationController] view] setFrame:[[self view] bounds]];
    [[[self internalNavigationController] view] setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [[self view] addSubview:_barContainer];

    _backButton = [[UIControl alloc] initWithFrame:CGRectMake(160 - 40, 0, 80, 86)];
    [_backButton addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    [[self barContainer] addSubview:_backButton];
    [_backButton setHidden:YES];
    
    _backButtonImageView = [[UIImageView alloc] initWithFrame:[_backButton bounds]];
    [_backButton addSubview:_backButtonImageView];
    [_backButtonImageView setContentMode:UIViewContentModeCenter];
    [_backButtonImageView setImage:[UIImage imageNamed:@"backarrow"]];
    
 //   [_backButton setBackgroundColor:[UIColor redColor]];
}

- (void)pop:(id)sender
{
    [[self internalNavigationController] popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([[[self internalNavigationController] viewControllers] indexOfObject:viewController] != 0) {
        [[self backButton] setHidden:NO];
        if(animated) {
            [[self backButton] setAlpha:0];
            [UIView animateWithDuration:0.2
                                  delay:[self transitionDuration:nil]
                                options:0
                             animations:^{
                                     [[self backButton] setAlpha:1];
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
        
    } else {
        [[self backButton] setHidden:YES];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    [self setTransitionOperation:operation];
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.45;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect fromInitial = [transitionContext initialFrameForViewController:fromVC];
    CGRect toFinal = [transitionContext finalFrameForViewController:toVC];
    CGRect fromFinal = CGRectMake(0, -fromInitial.size.height, fromInitial.size.width, fromInitial.size.height);
    CGRect toInitial = CGRectMake(0, [containerView bounds].size.height, toFinal.size.width, toFinal.size.height);

    if([self transitionOperation] == UINavigationControllerOperationPop) {
        CGRect t = fromFinal;
        fromFinal = toInitial;
        toInitial = t;
    }
    
    [[fromVC view] setFrame:fromInitial];
    [[toVC view] setFrame:toInitial];
    
    [containerView addSubview:[toVC view]];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         [[fromVC view] setFrame:fromFinal];
                         [[toVC view] setFrame:toFinal];
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:finished];
                     }];
}


@end

@implementation UIViewController (STKVerticalNavigationController)

- (STKVerticalNavigationController *)verticalController
{
    UIViewController *parent = [self parentViewController];
    while(parent != nil) {
        if([parent isKindOfClass:[STKVerticalNavigationController class]]) {
            return (STKVerticalNavigationController *)parent;
        }
        parent = [parent parentViewController];
    }
    return nil;
}

@end
