//
//  HASurveyScaleCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASurveyScaleCell.h"
#import "STKQuestion.h"
#import "STKQuestionOption.h"

@interface HASurveyScaleCell()

@property (nonatomic, strong) UILabel *disagreeLabel;
@property (nonatomic, strong) UILabel *agreeLabel;
@property (nonatomic, strong) UIView *wrapper;


@end

@implementation HASurveyScaleCell

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
    [self setBackgroundColor:[UIColor clearColor]];
    self.disagreeLabel = [[UILabel alloc] init];
    [self.disagreeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.disagreeLabel setText:@"Strongly Disagree"];
    [self.disagreeLabel setFont:STKFont(15)];
    [self.disagreeLabel setTextColor:[UIColor HATextColor]];
    [self addSubview:self.disagreeLabel];
    self.agreeLabel = [[UILabel alloc] init];
    [self.agreeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.agreeLabel setText:@"Strongly Agree"];
    [self.agreeLabel setFont:STKFont(15)];
    [self.agreeLabel setTextColor:[UIColor HATextColor]];
    [self addSubview:self.agreeLabel];
    self.wrapper = [[UIView alloc] init];
    [self.wrapper setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.wrapper];
    
}

#pragma mark Actors
- (void)scaleButtonTapped:(id)sender
{
    [[self delegate] scaleButtonTapped:sender cell:self];
}

- (void)layoutConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[d(==20)]-13-[w(==77)]" options:0 metrics:nil views:@{@"d": self.disagreeLabel, @"w": self.wrapper}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.disagreeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.f constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.agreeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.f constant:-8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.agreeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.disagreeLabel attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.wrapper attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
}

- (void)setQuestion:(STKQuestion *)question
{
    _question = question;
    NSMutableDictionary *viewsA = [NSMutableDictionary dictionary];
    NSMutableString *layoutA = [@"H:|-0-" mutableCopy];
    int margin = self.question.scale.integerValue == 5?9:4;
    int size = self.question.scale.integerValue == 5?41:28;
    for (int i = 1; i <= [self.question.scale integerValue]; ++i) {
        NSString *key = [NSString stringWithFormat:@"v%u", i];
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(scaleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.15f]];
        button.tag = i;
        [viewsA setObject:button forKey:key];
        [self.wrapper addSubview:button];
        [layoutA appendFormat:@"[%@(==%u)]", key, size];
        if (i != self.question.scale.integerValue) {
            [layoutA appendFormat:@"-%u-", margin];
        } else {
            [layoutA appendString:@"-0-|"];
        }
        
        UILabel *label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"%u", i]];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setFont:STKFont(21)];
        [label setTextColor:[UIColor HATextColor]];
        [self.wrapper addSubview:label];
        
        [self.wrapper addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
        [self.wrapper addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.wrapper attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        [self.wrapper addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeBottom multiplier:1.f constant:20]];
        [self.wrapper addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        
        
    }
    self.valueButtons = [viewsA allValues];
    
    [self.wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutA options:0 metrics:nil views:viewsA]];
}

@end
