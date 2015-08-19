//
//  HAPlainAvatarCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/16/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAPlainAvatarCell.h"

@implementation HAPlainAvatarCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureViews];
        [self configureConstraints];
    }
    return self;
}

#pragma mark Configuration

- (void)configureViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 48.0f)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
    [self setSelectedBackgroundView:bgView];
    
    self.containerView = [[UIView alloc] init];
    self.nameLabel = [[UILabel alloc] init];
    self.avatarView = [[STKAvatarView alloc] init];
    self.countView = [[UIView alloc] init];
    self.countLabel = [[UILabel alloc] init];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    
    [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nameLabel setFont:STKFont(18)];
    [self.nameLabel setTextColor:[UIColor HATextColor]];
    
    [self.avatarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.countView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.countView setBackgroundColor:[UIColor colorWithRed:0.3 green:0.4 blue:.7 alpha:1]];
    [self.countView.layer setCornerRadius:11.f];
    
    [self.countLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.countLabel setTextColor:[UIColor HATextColor]];
    [self.countLabel setFont:STKBoldFont(12)];
    [self.countLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.avatarView];
    [self.containerView addSubview:self.nameLabel];
    [self.containerView addSubview:self.countView];
    [self.countView addSubview:self.countLabel];
}

- (void)configureConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:-1]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[c]-1-|" options:0 metrics:nil views:@{@"c": self.containerView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[c]-0-|" options:0 metrics:nil views:@{@"c": self.containerView}]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[av(==30)]-9-[nl]" options:0 metrics:nil views:@{@"av": self.avatarView, @"nl": self.nameLabel}]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.countView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.countView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1.f constant:-8.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.countView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeHeight multiplier:1.f constant:-8.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.countView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.countView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    
//    [self.countView addConstraint:[NSLayoutConstraint constraintWithItem:self.countLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.countView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
//    [self.countView addConstraint:[NSLayoutConstraint constraintWithItem:self.countLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.countView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.countView addConstraint:[NSLayoutConstraint constraintWithItem:self.countLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.countView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.countView addConstraint:[NSLayoutConstraint constraintWithItem:self.countLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.countView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
}

@end
