//
//  HASurveyAvatarHeaderCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASurveyAvatarHeaderCell.h"


@implementation HASurveyAvatarHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    
    [self.nameLabel setText:@""];
    
    [self.avatarView setImage:nil];
    [super prepareForReuse];
}

#pragma mark Configuration
- (void)setupViews
{
    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.avatarView = [[STKAvatarView alloc] init];
    [self.avatarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.avatarView];
    [self addSubview:self.nameLabel];
    [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.nameLabel setFont:STKFont(13.5)];
    [self.nameLabel setTextColor:[UIColor HATextColor]];
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[av(==30)]-12-[l]" options:0 metrics:nil views:@{@"av": self.avatarView, @"l": self.nameLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeCenterY   relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterY   relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterX   relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:21.f]];
}

@end
