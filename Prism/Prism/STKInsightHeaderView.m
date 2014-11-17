//
//  STKInsightHeaderView.m
//  Prizm
//
//  Created by Jonathan Boone on 10/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInsightHeaderView.h"
#import "STKAvatarView.h"

NSString *const HAImageLikeInsightButton = @"trust_check";
NSString *const HAImageDislikeInsightButton = @"trust_reject";

@implementation STKInsightHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.avatarView = [[STKAvatarView alloc] init];
    self.avatarButton = [[UIControl alloc] init];
    self.backdropFadeView = [[UIImageView alloc] init];
    self.posterLabel = [[UILabel alloc] init];
    self.likeButton = [[UIButton alloc] init];
    self.dislikeButton = [[UIButton alloc] init];
    
    [self.backdropFadeView setAlpha:0.f];
    
    [self.posterLabel setFont:STKFont(16)];
    [self.posterLabel setTextColor:STKTextColor];
    
    [self.avatarButton setBackgroundColor:[UIColor clearColor]];
    
    [self.likeButton setImage:[UIImage imageNamed:HAImageLikeInsightButton] forState:UIControlStateNormal];
    [self.dislikeButton setImage:[UIImage imageNamed:HAImageDislikeInsightButton] forState:UIControlStateNormal];
    
    [self addSubview:self.backdropFadeView];
    [self addSubview:self.avatarView];
    [self addSubview:self.posterLabel];
    [self addSubview:self.avatarButton];
    [self addSubview:self.likeButton];
    [self addSubview:self.dislikeButton];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    for(UIView *v in [self subviews]) {
        [v setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[a(==36)]-8-[pv]" options:0 metrics:nil views:@{@"a": self.avatarView, @"pv": self.posterLabel}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[a(36)]" options:0 metrics:nil views:@{@"a": self.avatarView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v(36)]" options:0 metrics:nil views:@{@"v": self.posterLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.posterLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.likeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.posterLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dislikeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.likeButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[d(30.0)]-15-[l(30.0)]-10-|" options:0 metrics:nil views:@{@"l": self.likeButton, @"d": self.dislikeButton}]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[d(30.0)]" options:0 metrics:nil views:@{@"d": self.dislikeButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[l(30.0)]" options:0 metrics:nil views:@{@"l": self.likeButton}]];
    
}



@end
