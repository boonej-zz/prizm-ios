//
//  STKMenuView.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKMenuView.h"
#import "STKMenuButton.h"
#import "STKNotificationBadge.h"

@interface STKMenuView () <UIDynamicAnimatorDelegate>
@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) NSLayoutConstraint *blurHeightConstraint;
@property (nonatomic, strong) STKNotificationBadge *badgeView;
@property (nonatomic, strong) CALayer *underlayLayer;
@end

@implementation STKMenuView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 140)];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setClipsToBounds:YES];

        [self addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        
        _backgroundImageView = [[UIImageView alloc] init];
        [_backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_backgroundImageView setClipsToBounds:YES];

        _buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        [_buttonContainerView setClipsToBounds:YES];
        [self addSubview:_buttonContainerView];
        
        
        [_buttonContainerView addSubview:_backgroundImageView];
        [_buttonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_buttonContainerView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:0]];
        [_buttonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_buttonContainerView
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1
                                                          constant:0]];
        [_buttonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_buttonContainerView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1
                                                          constant:0]];
        _blurHeightConstraint = [NSLayoutConstraint constraintWithItem:_backgroundImageView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:140];
        [_backgroundImageView addConstraint:_blurHeightConstraint];
        
        
        _underlayLayer = [CALayer layer];
        [_underlayLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        [_underlayLayer setFrame:[_buttonContainerView bounds]];
        [[_buttonContainerView layer] addSublayer:_underlayLayer];
        
        
        STKMenuButton *b0 = [[STKMenuButton alloc] init];
        STKMenuButton *b1 = [[STKMenuButton alloc] init];
        STKMenuButton *b2 = [[STKMenuButton alloc] init];
        STKMenuButton *b3 = [[STKMenuButton alloc] init];
        STKMenuButton *b4 = [[STKMenuButton alloc] init];
        STKMenuButton *b5 = [[STKMenuButton alloc] init];
        _buttons = @[b0, b1, b2, b3, b4, b5];

        for(UIControl *ctl in [self buttons]) {
            [ctl addTarget:self
                    action:@selector(buttonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
            [ctl setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_buttonContainerView addSubview:ctl];
        }
        [_buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v0(==v1)][v1(==v2)][v2]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"v0" : b0, @"v1" : b1, @"v2" : b2}]];
        [_buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v0(==v1)][v1(==v2)][v2]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"v0" : b3, @"v1" : b4, @"v2" : b5}]];
        [_buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v0(==v1)][v1(==70)]|" options:0 metrics:nil views:@{@"v0" : b0, @"v1" : b3}]];
        [_buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v0(==v1)][v1(==70)]|" options:0 metrics:nil views:@{@"v0" : b1, @"v1" : b4}]];
        [_buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v0(==v1)][v1(==70)]|" options:0 metrics:nil views:@{@"v0" : b2, @"v1" : b5}]];

        
        _badgeView = [[STKNotificationBadge alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        [_badgeView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_buttonContainerView addSubview:_badgeView];
        
        [_badgeView addConstraint:[NSLayoutConstraint constraintWithItem:_badgeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20]];
        [_badgeView addConstraint:[NSLayoutConstraint constraintWithItem:_badgeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
        [_buttonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_badgeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                                            toItem:b4 attribute:NSLayoutAttributeCenterX multiplier:1 constant:20]];
        [_buttonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_badgeView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                                            toItem:b4 attribute:NSLayoutAttributeCenterY multiplier:1 constant:-15]];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [[self underlayLayer] setFrame:[[self buttonContainerView] bounds]];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    [[self backgroundImageView] setImage:_backgroundImage];
    
    if(_backgroundImage) {
        CGSize imgSize = [_backgroundImage size];
        CGSize viewSize = [self bounds].size;
        
        float ratio = viewSize.width / imgSize.width;
        
        float height = imgSize.height * ratio;
        [[self blurHeightConstraint] setConstant:height];
    } else {
        [[self blurHeightConstraint] setConstant:0];
    }
    [[self backgroundImageView] setNeedsLayout];
}

- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    
}

- (void)setNotificationCount:(int)notificationCount
{
    [[self badgeView] setCount:notificationCount];
}

- (void)setItems:(NSArray *)items
{
    if([items count] != [[self buttons] count])
        @throw [NSException exceptionWithName:@"STKMenuView" reason:@"Mismatch in STKMenu items - requires 6" userInfo:nil];
    
    for(int i = 0; i < [items count]; i++) {
        UITabBarItem *item = [items objectAtIndex:i];
        [[[self buttons] objectAtIndex:i] setItem:item];
    }
}

- (void)setVisible:(BOOL)visible
{
    [self setVisible:visible animated:NO];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated
{
    [self setHidden:!visible];
    
    if(!visible) {
        [self setBackgroundImage:nil];
        [[self underlayLayer] setOpacity:0.0];
    } else {
        [[self underlayLayer] setOpacity:0.5];
    }
}

- (void)dismiss:(id)sender
{
    [[self delegate] menuView:self didSelectItemAtIndex:[self selectedIndex]];
}

- (BOOL)isVisible
{
    return ![self isHidden];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if(hidden)
        [[self animator] removeAllBehaviors];
}

- (void)performOutAnimationWithCompletion:(void (^)(void))block
{
    block();
//    [CATransaction begin];
}

- (void)performInAnimation
{/*
    [self layoutIfNeeded];
    for(UIControl *ctl in [self buttons]) {
        CGPoint p = [ctl center];
        if([[self buttons] indexOfObject:ctl] < 3)
            p.y -= 100 + rand() % 50;
        else
            p.y -= 100 + rand() % 50;
        [ctl setCenter:p];
    }
    
    UIGravityBehavior *b = [[UIGravityBehavior alloc] initWithItems:[self buttons]];
    [b setMagnitude:0.7];
    
    NSArray *buttonsTop = @[[self buttons][0], [self buttons][1], [self buttons][2]];
    NSArray *buttonsBottom = @[[self buttons][3], [self buttons][4], [self buttons][5]];
    
    UICollisionBehavior *collisionBottom = [[UICollisionBehavior alloc] initWithItems:buttonsBottom];
    [collisionBottom addBoundaryWithIdentifier:@"bottomBottom"
                               fromPoint:CGPointMake(0, [self bounds].size.height + 1)
                                 toPoint:CGPointMake([self bounds].size.width, [self bounds].size.height + 1)];
    [collisionBottom setCollisionMode:UICollisionBehaviorModeBoundaries];
    
    UICollisionBehavior *collisionTop = [[UICollisionBehavior alloc] initWithItems:buttonsTop];
    [collisionTop addBoundaryWithIdentifier:@"topBottom"
                               fromPoint:CGPointMake(0, [self bounds].size.height / 2.0 + 1)
                                 toPoint:CGPointMake([self bounds].size.width, [self bounds].size.height / 2.0 + 1)];
    [collisionTop setCollisionMode:UICollisionBehaviorModeBoundaries];
    
    if(![self animator]) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        [[self animator] setDelegate:self];
    }
    [[self animator] addBehavior:b];
    [[self animator] addBehavior:collisionBottom];
    [[self animator] addBehavior:collisionTop];*/
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    NSLog(@"Pause");
    [[self animator] removeAllBehaviors];
    [self setNeedsLayout];
}

- (void)buttonTapped:(id)sender
{
    [[self delegate] menuView:self didSelectItemAtIndex:(int)[[self buttons] indexOfObject:sender]];
}


@end
