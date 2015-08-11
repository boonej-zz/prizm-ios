//
//  HASurveyHeaderCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASurveyHeaderCell.h"

@interface HASurveyHeaderCell()

@property (nonatomic, strong) UIImageView *iv;

@end

@implementation HASurveyHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutViews];
        [self layoutConstraints];
    }
    return self;
}

#pragma mark Configuration

- (void)layoutViews
{
    [self setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.6f]];
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleLabel setFont:STKFont(15)];
    [self.titleLabel setTextColor:[UIColor HATextColor]];
    [self.titleLabel setNumberOfLines:2];
    [self addSubview:self.titleLabel];
    self.iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_survey_sm"]];
    [self.iv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.iv];

}

- (void)layoutConstraints
{

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[ht(==232)]-43-[iv(==16)]-14-|" options:0 metrics:nil views:@{@"ht": self.titleLabel, @"iv": self.iv}]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[ht]-0-|" options:0 metrics:nil views:@{@"ht": self.titleLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.iv attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iv attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
}

@end
