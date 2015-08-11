//
//  STKLeaderBoardCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKLeaderBoardCell.h"

@interface STKLeaderBoardCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *ribbonImage;


@end

@implementation STKLeaderBoardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Configuration

- (void)setupViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.containerView = [[UIView alloc] init];
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self addSubview:self.containerView];
    
    self.positionLabel = [[UILabel alloc] init];
    [self.positionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.positionLabel setFont:STKFont(13)];
    [self.positionLabel setTextColor:[UIColor HATextColor]];
    [self.positionLabel setTextAlignment:NSTextAlignmentCenter];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
    [bgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.positionLabel addSubview:bgView];
    [self.positionLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bg]-0-|" options:0 metrics:nil views:@{@"bg": bgView}]];
    [self.positionLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bg]-0-|" options:0 metrics:nil views:@{@"bg": bgView}]];
    [self.containerView addSubview:self.positionLabel];
    
    self.avatarView = [[STKAvatarView alloc] init];
    [self.avatarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView addSubview:self.avatarView];
    
    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nameLabel setFont:STKFont(13.f)];
    [self.nameLabel setTextColor:[UIColor HATextColor]];
    [self.containerView addSubview:self.nameLabel];
    
    self.ribbonImage = [[UIImageView alloc] init];
    [self.ribbonImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView addSubview:self.ribbonImage];
    
    self.pointsLabel = [[UILabel alloc] init];
    [self.pointsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pointsLabel setFont:STKFont(13.f)];
    [self.pointsLabel setTextColor:[UIColor HATextColor]];
    [self.containerView addSubview:self.pointsLabel];
}

- (void)setupConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:-1.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:-1.f]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pl(==24)]-18-[av(==30)]-11-[nl]-0-[ri(==20)]-11-[pt(==45)]-10-|" options:0 metrics:nil views:@{@"pl": self.positionLabel, @"av": self.avatarView, @"nl": self.nameLabel, @"ri": self.ribbonImage, @"pt": self.pointsLabel}]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.positionLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.ribbonImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.pointsLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.positionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.positionLabel attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.ribbonImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.ribbonImage attribute:NSLayoutAttributeWidth multiplier:1.1f constant:0.f]];

}

- (void)setRanking:(long)ranking
{
    _ranking = ranking;
    UIImage *image = nil;
    
    switch (ranking) {
        case 1:
            image = [UIImage imageNamed:@"icon_medal_gold"];
            break;
        case 2:
            image = [UIImage imageNamed:@"icon_medal_silver"];
            break;
        case 3:
            image = [UIImage imageNamed:@"icon_medal_bronze"];
            break;
        default:
            break;
    }
    
    self.positionLabel.text = [NSString stringWithFormat:@"%ld", ranking];
    [self.ribbonImage setImage:image];
}

@end
