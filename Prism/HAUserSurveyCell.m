//
//  HAUserSurveyCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAUserSurveyCell.h"

@interface HAUserSurveyCell()

@property (nonatomic, strong) UIView *rankWrapper;

@end

@implementation HAUserSurveyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark Configuration

- (void)setupViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectedBackgroundView:[[UIView alloc] init]];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleLabel setFont:STKFont(12.f)];
    [self.titleLabel setTextColor:[UIColor HATextColor]];
    [self addSubview:self.titleLabel];
    
    
    self.rankWrapper = [[UIView alloc] init];
    [self.rankWrapper setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.rankWrapper];
    
    self.rankLabel = [[UILabel alloc] init];
    [self.rankLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rankLabel setFont:STKFont(12.f)];
    [self.rankLabel setTextColor:[UIColor HATextColor]];
    [self.rankLabel setTextAlignment:NSTextAlignmentCenter];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
    [self.rankLabel addSubview:iv];
//    [self.rankLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[iv]-0-|" options:0 metrics:nil views:@{@"iv": iv}]];
//    [self.rankLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[iv]-0-|" options:0 metrics:nil views:@{@"iv": iv}]];
    [self.rankWrapper addSubview:self.rankLabel];
    [self.rankWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rl(==24)]" options:0 metrics:nil views:@{@"rl": self.rankLabel}]];
    [self.rankWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rl(==24)]|" options:0 metrics:nil views:@{@"rl": self.rankLabel}]];
    
    self.durationLabel = [[UILabel alloc] init];
    [self.durationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.durationLabel setFont:STKFont(12.f)];
    [self.durationLabel setTextColor:[UIColor HATextColor]];
 
    [self addSubview:self.durationLabel];
    
    self.pointsLabel = [[UILabel alloc] init];
    [self.pointsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pointsLabel setFont:STKFont(12.f)];
    [self.pointsLabel setTextColor:[UIColor HATextColor]];
  
    [self addSubview:self.pointsLabel];
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[tl]-2-[rl(==35)]-16-[dl(==56)]-13-[pt(==42)]-15-|" options:0 metrics:nil views:@{@"tl": self.titleLabel, @"rl": self.rankWrapper, @"dl": self.durationLabel, @"pt": self.pointsLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rankLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pointsLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
}

@end
