//
//  HASurveyMultipleCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASurveyMultipleCell.h"
#import "STKQuestion.h"
#import "STKQuestionOption.h"

@interface HASurveyMultipleCell()



@end

@implementation HASurveyMultipleCell

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
}

- (void)layoutConstraints
{
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setQuestion:(STKQuestion *)question
{
    _question = question;
    NSMutableDictionary *rowKeys = [NSMutableDictionary dictionary];
    NSMutableString *formatString = [[NSMutableString alloc] initWithString:@"V:|-(>=12)-"];
    [self.question.options enumerateObjectsUsingBlock:^(STKQuestionOption *option, BOOL *stop) {
        NSString *key = [NSString stringWithFormat:@"b%ld", (long)option.order.integerValue];
        UIButton *button = [[UIButton alloc] init];
        [button setFrame:CGRectMake(0, 0, 24, 24)];
        [button setTag:option.order.integerValue];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setImage:[UIImage imageNamed:@"btn_radio"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"btn_radio_selected"] forState:UIControlStateSelected];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button addTarget:self action:@selector(multipleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rowKeys setObject:button forKey:key];
        UILabel *label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setText:option.text];
        [label setFont:STKFont(15)];
        [label setTextColor:[UIColor HATextColor]];
        [label setNumberOfLines:2];
        [label setMinimumScaleFactor:0.8f];
        [self addSubview:button];
        [self addSubview:label];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[b(==24)]-10-[l]-0-|" options:0 metrics:nil views:@{@"b": button, @"l": label}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        [formatString appendFormat:@"[%@(==24)]", key];
        if (option.order.integerValue != self.question.options.count) {
            [formatString appendString:@"-12-"];
        } else {
            [formatString appendString:@""];
        }
    }];
    self.valueButtons = [rowKeys allValues];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:rowKeys]];
}

#pragma mark Actors
- (void)multipleButtonTapped:(id)sender
{
    [self.delegate multipleButtonTapped:sender cell:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
   
    // Configure the view for the selected state
}

@end
