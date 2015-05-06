//
//  STKUserSelectCellTableViewCell.m
//  Prizm
//
//  Created by Jonathan Boone on 5/2/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "STKUserSelectCellTableViewCell.h"



@interface STKUserSelectCellTableViewCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, getter=shouldOverrideAccessoryView) BOOL overrideAccessoryView;

@end

@implementation STKUserSelectCellTableViewCell

- (id)init
{
    self = [super init];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setAccessoryView:(UIView *)accessoryView
{
    [self setOverrideAccessoryView:YES];
    [_toggle setHidden:YES];
    [super setAccessoryView:accessoryView];
}

- (void)setupCell
{
    _containerView = [[UIView alloc] init];
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _avatarView = [[STKAvatarView alloc] init];
    [_avatarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _label = [[UILabel alloc] init];
    [_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    _toggle = [[UIView alloc] init];
    [_toggle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_containerView addSubview:_avatarView];
    [_containerView addSubview:_label];
    [_containerView addSubview:_toggle];
    [self addSubview:_containerView];
    [self setupConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_toggle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:22]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[av(==30)]-10-[l]-5-[t(==22)]-24-|" options:0 metrics:nil views:@{@"av": _avatarView, @"l": _label, @"t": _toggle}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_toggle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)layoutSubviews
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_containerView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2f]];
    [_label setFont:STKFont(14)];
    [_label setTextColor:[UIColor HATextColor]];
    [_toggle.layer setBorderColor:[UIColor clearColor].CGColor];
    [_toggle.layer setCornerRadius:11.f];
    if (self.selected) {
        [_toggle setBackgroundColor:[UIColor colorWithRed:61.f/255.f green:112.f/255.f blue:177.f/255.f alpha:1.f]];
    } else {
        [_toggle setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
    }
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if ([self shouldOverrideAccessoryView]) {
        return;
    }
    if (self.selected) {
        [_toggle setBackgroundColor:[UIColor colorWithRed:61.f/255.f green:112.f/255.f blue:177.f/255.f alpha:1.f]];
    } else {
        [_toggle setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
    }
    
}

@end
