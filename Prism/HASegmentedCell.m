//
//  HASegmentedCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/13/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASegmentedCell.h"

@interface HASegmentedCell()

@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation HASegmentedCell


#pragma mark Configuration

- (id)initWithItems:(NSArray *)items;
{
    self = [super init];
    if (self) {
        _items = items;
        [self layoutViews];
        [self layoutConstraints];
    }
    return self;
}


- (void)layoutViews
{
    [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.05f]];
    if (IS_HEIGHT_GTE_568 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [self.blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.blurView setFrame:CGRectMake(0, 0, 320, 25)];
    } else {
        self.blurView = [[UIView alloc] init];
    }
    [self addSubview:self.blurView];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:self.items];
    [self.segmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor HATextColor], NSFontAttributeName: STKFont(12)} forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: STKFont(12)} forState:UIControlStateSelected];
    [self.segmentedControl setTintColor:[UIColor colorWithWhite:1.f alpha:0.3f]];
    [self.segmentedControl.layer setCornerRadius:0];
    [self addSubview:self.segmentedControl];
}

- (void) layoutConstraints
{
    if (IS_HEIGHT_GTE_568 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bv]-0-|" options:0 metrics:nil views:@{@"bv": self.blurView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bv]-0-|" options:0 metrics:nil views:@{@"bv": self.blurView}]];
    }

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:-10.f]];
    } else {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    }
    
}

@end
