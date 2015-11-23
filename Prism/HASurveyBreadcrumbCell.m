//
//  HASurveyBreadcrumbCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASurveyBreadcrumbCell.h"
#import "STKSurvey.h"
#import "STKQuestion.h"

@interface HASurveyBreadcrumbCell()

@property (nonatomic, strong) UIView *wrapper;
@property (nonatomic, strong) UILabel *positionLabel;
@property (nonatomic, strong) UILabel *currentNumber;
@property (nonatomic, strong) UITextView *questionView;

@end

@implementation HASurveyBreadcrumbCell

#pragma mark Configuration

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutViews];
        [self layoutConstraints];
    }
    return self;
}

- (void)layoutViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    self.wrapper = [[UIView alloc] init];
    [self.wrapper setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.wrapper];
    self.positionLabel = [[UILabel alloc] init];
    [self.positionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.positionLabel];
    self.currentNumber = [[UILabel alloc] init];
    [self.currentNumber setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.currentNumber setFont:STKFont(36)];
    [self.currentNumber setTextColor:[UIColor HATextColor]];
    [self.currentNumber sizeToFit];
    [self addSubview:self.currentNumber];
    
    self.questionView = [[UITextView alloc] init];
    [self.questionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.questionView setFont:STKBoldFont(15)];
    [self.questionView setTextColor:[UIColor HATextColor]];
    [self.questionView setEditable:NO];
    [self.questionView setScrollEnabled:NO];
    
    [self.questionView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.15f]];
    [self.questionView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.questionView.layer setBorderWidth:1.f];
    [self.questionView setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.questionView];
    
}

- (void)layoutConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=8)-[w(==21)]-(<=27)-[cn]-(<=14)-[qv(>=35)]-(>=0)-|" options:0 metrics:nil views:@{@"w": self.wrapper, @"cn": self.currentNumber, @"qv": self.questionView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.currentNumber attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.wrapper attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.wrapper attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[w]-16-[pl]" options:0 metrics:nil views:@{@"w":self.wrapper, @"pl": self.positionLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.positionLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.wrapper attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.positionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.wrapper attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-36-[qv(==248)]-36-|" options:0 metrics:nil views:@{@"qv": self.questionView}]];
}

- (void)setQuestionNumber:(NSInteger)questionNumber
{
    _questionNumber = questionNumber;
    [self.currentNumber setText:[NSString stringWithFormat:@"%ld", (long)self.questionNumber]];
    if (self.survey) {
        [self setSurvey:self.survey];
    }
}

- (void)setSurvey:(STKSurvey *)survey
{
    _survey = survey;
    NSMutableDictionary *bcs = [NSMutableDictionary dictionary];
    for (int i = 0; i != [survey.numberOfQuestions integerValue]; ++i) {
        BOOL active = (i + 1) <= self.questionNumber;
        UIView *v = [self breadcrumbIsActive:active];
        [self.wrapper addSubview:v];
        [self.wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v": v}]];
        [bcs setObject:v forKey:[NSString stringWithFormat:@"v%u", i]];
    }
    NSArray *keys = [bcs allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
       return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *formatString = [@"H:|-0-" mutableCopy];
    NSEnumerator *e = [keys objectEnumerator];
    for (NSString *obj in e) {
        [formatString appendFormat:@"[%@(==21)]", obj];
        if (obj != [keys lastObject]) {
            [formatString appendString:@"-4-"];
        } else {
            [formatString appendString:@"-0-|"];
        }
    }
    [self.wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:bcs]];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)self.questionNumber] attributes:@{NSFontAttributeName: STKBoldFont(15), NSForegroundColorAttributeName: [UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:1]}];
    NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"/%ld", (long)[self.survey.numberOfQuestions integerValue]] attributes:@{NSFontAttributeName: STKFont(15), NSForegroundColorAttributeName: [UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:0.5]}];
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithAttributedString:attString];
    [finalString appendAttributedString:attString2];
    [self.positionLabel setAttributedText:finalString];
    STKQuestion *question = [[survey.questions allObjects] objectAtIndex:(self.questionNumber - 1)];
    [self.questionView setText:[question text]];
    
}

#pragma mark Workers

- (UIView *)breadcrumbIsActive:(BOOL)active
{
    UIView *view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIColor *color = nil;
    if (active) {
        color = [UIColor colorWithRed:0.f/255.f green:187.f/255.f blue:74.f/255.f alpha:1.f];
    } else {
        color = [UIColor colorWithWhite:1 alpha:0.15f];
    }
    [view setBackgroundColor:color];
    return view;
}

@end
