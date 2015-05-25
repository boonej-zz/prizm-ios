//
//  HALabelAccessoryTableViewCell.m
//  Prizm
//
//  Created by Jonathan Boone on 5/2/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HALabelAccessoryTableViewCell.h"

@interface HALabelAccessoryTableViewCell()

@property (nonatomic, strong) UIView *containerView;

@end

@implementation HALabelAccessoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell
{
    _containerView = [[UIView alloc] init];
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _label = [[UILabel alloc] init];
    [_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_containerView];
    [_containerView addSubview:_label];
    _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    [self setAccessoryView:[self accessoryImageView]];
    [self setupConstraints];
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:-1.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:-1.f]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[tl]-40-|" options:0 metrics:nil views:@{@"tl": self.label}]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tl(==24)]" options:0 metrics:nil views:@{@"tl": self.label}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)layoutSubviews {
    [[self label] setFont:STKFont(15.f)];
    [[self containerView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    [[self label] setTextColor:[UIColor whiteColor]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [super layoutSubviews];
}

@end
