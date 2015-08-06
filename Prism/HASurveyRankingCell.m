//
//  HASurveyRankingCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASurveyRankingCell.h"

@interface HASurveyRankingCell()

@property (nonatomic, strong) UILabel *rankTitle;
@property (nonatomic, strong) UILabel *pointsTitle;
@property (nonatomic, strong) UILabel *surveysTitle;
@property (nonatomic, strong) UIImageView *surveysIcon;

@end

@implementation HASurveyRankingCell

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
    UIView *leftBlock = [[UIView alloc] init];
    [leftBlock setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *rightBlock = [[UIView alloc] init];
    [rightBlock setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.rankTitle = [[UILabel alloc] init];
    [self.rankTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rankTitle setText:@"Rank"];
    [self.rankTitle setFont:STKFont(15)];
    [self.rankTitle setTextColor:[UIColor HATextColor]];
    
    [self addSubview:self.rankTitle];
    
    self.rankingLabel = [[UILabel alloc] init];
    [self.rankingLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rankingLabel setFont:STKFont(30)];
    [self.rankingLabel setTextColor:[UIColor colorWithRed:209.f/255.f green:139.f/255.f blue:255.f/255.f alpha:1.f]];
    [self addSubview:self.rankingLabel];
    
    self.pointsTitle = [[UILabel alloc] init];
    [self.pointsTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pointsTitle setText:@"Points"];
    [self.pointsTitle setFont:STKFont(15)];
    [self.pointsTitle setTextColor:[UIColor HATextColor]];
    
    self.pointsLabel = [[UILabel alloc] init];
    [self.pointsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pointsLabel setFont:STKFont(30)];
    [self.pointsLabel setTextColor:[UIColor colorWithRed:80.f/255.f green:184.f/255.f blue:73.f/255.f alpha:1.f]];
    [self addSubview:self.pointsLabel];
    
    [self addSubview:self.pointsTitle];
    
    self.surveysTitle = [[UILabel alloc] init];
    [self.surveysTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.surveysTitle setText:@"Surveys"];
    [self.surveysTitle setFont:STKFont(15)];
    [self.surveysTitle setTextColor:[UIColor HATextColor]];
    [self.surveysTitle setUserInteractionEnabled:YES];
    [self addSubview:self.surveysTitle];
    UITapGestureRecognizer *tr0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(surveysTapped:)];
    [self.surveysTitle addGestureRecognizer:tr0];
    
    self.surveysIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_survey_sm"]];
    [self.surveysIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.surveysIcon setUserInteractionEnabled:YES];
    [self addSubview:self.surveysIcon];
    UITapGestureRecognizer *tr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(surveysTapped:)];
    [self.surveysIcon addGestureRecognizer:tr1];
    
    self.surveysLabel = [[UILabel alloc] init];
    [self.surveysLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.surveysLabel setFont:STKFont(23)];
    [self.surveysLabel setTextColor:[UIColor whiteColor]];
    [self.surveysLabel setUserInteractionEnabled:YES];
    [self addSubview:self.surveysLabel];
    UITapGestureRecognizer *tr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(surveysTapped:)];
    [self.surveysLabel addGestureRecognizer:tr2];
    
    [self.rankTitle setTextAlignment:NSTextAlignmentCenter];
    [self.pointsTitle setTextAlignment:NSTextAlignmentCenter];
    [self.surveysTitle setTextAlignment:NSTextAlignmentCenter];
    
    
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rt(>=160)]-0-[pt(>=160)]-0-|" options:0 metrics:nil views:@{@"rt": self.rankTitle, @"pt": self.pointsTitle}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[rt(==14)]-13-[rl(==26)]-25-[st(==16)]-13-[sl(==20)]" options:0 metrics:nil views:@{@"rt": self.rankTitle, @"rl": self.rankingLabel, @"st": self.surveysTitle, @"sl": self.surveysLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pointsTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.rankTitle attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rankingLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.rankTitle attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pointsLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.pointsTitle attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pointsLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.rankingLabel attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.surveysTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[si(==16)]-7-[sl]" options:0 metrics:nil views:@{@"si": self.surveysIcon, @"sl": self.surveysLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.surveysIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.surveysLabel attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.surveysLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:11]];
    
}

- (void)drawRect:(CGRect)rect
{
    CGFloat x = rect.size.width/2;
    CGFloat startY = 36;
    CGFloat endY = 106;
    CGContextRef c=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1.0);
    CGFloat red[4]={168.f/255.f, 171.f/255.f, 176.f/255.f, 0.5f};
    CGContextSetStrokeColor(c, red);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x, startY);
    CGContextAddLineToPoint(c, x, endY);
    CGContextStrokePath(c);
    
    CGFloat y = endY + 8;
    CGFloat startX = 32;
    CGFloat endX = rect.size.width - 32;
    CGContextSetStrokeColor(c, red);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, startX, y);
    CGContextAddLineToPoint(c, endX, y);
    CGContextStrokePath(c);
    
    [super drawRect:rect];
}

- (void)surveysTapped:(id)gesture
{
    if (self.delegate) {
        [self.delegate surveyCountTapped:self];
    }
}

@end
