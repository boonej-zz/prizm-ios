//
//  STKMenuView.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKMenuView.h"
#import "STKMenuButton.h"

@interface STKMenuView () <UIDynamicAnimatorDelegate>

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@end

@implementation STKMenuView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 100)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
//        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setClipsToBounds:YES];

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
            [self addSubview:ctl];
        }
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v0(==v1)][v1(==v2)][v2]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"v0" : b0, @"v1" : b1, @"v2" : b2}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v0(==v1)][v1(==v2)][v2]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"v0" : b3, @"v1" : b4, @"v2" : b5}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v0(==v1)][v1(==50)]|" options:0 metrics:nil views:@{@"v0" : b0, @"v1" : b3}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v0(==v1)][v1(==50)]|" options:0 metrics:nil views:@{@"v0" : b1, @"v1" : b4}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v0(==v1)][v1(==50)]|" options:0 metrics:nil views:@{@"v0" : b2, @"v1" : b5}]];
    }
    return self;

}

- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    for(int i = 0; i < [[self buttons] count]; i++) {
        STKMenuButton *mb = [[self buttons] objectAtIndex:i];
        [mb setSelected:i == _selectedIndex];
    }
    
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
    [[self delegate] menuView:self didSelectItemAtIndex:[[self buttons] indexOfObject:sender]];
}


@end
