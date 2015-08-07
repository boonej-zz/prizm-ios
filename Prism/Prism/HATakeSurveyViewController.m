//
//  HATakeSurveyViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HATakeSurveyViewController.h"
#import "STKSurvey.h"
#import "STKQuestion.h"
#import "STKQuestionOption.h"
#import "STKOrganization.h"
#import "STKUser.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"
#import "UISurveyDoneViewController.h"

@interface HATakeSurveyViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) STKSurvey *survey;
@property (nonatomic) NSInteger questionNumber;
@property (nonatomic, strong) STKQuestion *question;
@property (nonatomic, strong) NSArray *valueButtons;
@property (nonatomic) NSInteger selectedValue;


@end

@implementation HATakeSurveyViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (id)initWithSurvey:(id)survey
{
    self = [self init];
    if (self) {
        self.survey = survey;
        self.questionNumber = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
    self.title = @"Survey";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HeaderCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Breadcrumb"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Scale"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Button"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Multiple"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setQuestionNumber:(NSInteger)questionNumber
{
    if (self.survey) {
        self.question = [[self.survey.questions allObjects] objectAtIndex:(questionNumber - 1)];
    }
    _questionNumber = questionNumber;
}

#pragma mark - Initial Layout
- (void)setupViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
}

#pragma mark - Actors
- (void)scaleButtonTapped:(UIButton *)sender
{
    [self.valueButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        if (button != sender) {
            [button setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.15]];
        }
    }];
    [sender setBackgroundColor:[UIColor colorWithRed:0.f/255.f green:187.f/255.f blue:74.f/255.f alpha:1.f]];
    self.selectedValue = sender.tag;
}

- (void)multipleButtonTapped:(UIButton *)sender
{
    [self.valueButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        if (button != sender) {
            [button setSelected:NO];
        }
    }];
    [sender setSelected:YES];
    self.selectedValue = sender.tag;
}

- (void)nextButtonTapped:(UIButton *)button
{
    if (self.selectedValue) {
        [[STKUserStore store] submitSurveyAnswerForUser:[[STKUserStore store] currentUser] question:self.question value:self.selectedValue completion:^(STKQuestion *question, NSError *err) {
            if (self.questionNumber != self.survey.questions.count) {
                HATakeSurveyViewController *tsc = [[HATakeSurveyViewController alloc] initWithSurvey:self.survey];
                [tsc setQuestionNumber:(self.questionNumber + 1)];
                [self.navigationController pushViewController:tsc animated:YES];
            } else {
                [[STKUserStore store] finalizeSurveyForUser:[[STKUserStore store] currentUser] survey:self.survey completion:^(STKSurvey *survey, NSError *err) {
                    UISurveyDoneViewController *sdc = [[UISurveyDoneViewController alloc] init];
                    if ([survey isKindOfClass:[NSArray class]]) {
                        survey  = [(NSArray *)survey objectAtIndex:0];
                    }
                    [sdc setSurvey:survey];
                    [self.navigationController pushViewController:sdc animated:YES];
                }];
            }
        }];
        
    }
}

#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self headerCell];
    } else if (indexPath.section == 1) {
        return [self breadcrumb];
    } else if (indexPath.section == 2) {
        if ([self.question.type isEqualToString:@"scale"]) {
            return [self scaleCell];
        } else {
            return [self multipleCell];
        }
    } else if (indexPath.section == 3) {
        return [self buttonCell];
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 64;
    } else if (indexPath.section == 1) {
        return 168;
    } else if (indexPath.section == 2) {
        if ([self.question.type isEqualToString:@"scale"]) {
            return 126;
        } else {
            return 170;
        }
    } else if (indexPath.section == 3) {
        return 85;
    }
    return 0;
}



#pragma mark - Table View Delegate

#pragma mark Cell Creators
- (UITableViewCell *)headerCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [cell setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.6f]];
    UILabel *headerText = [[UILabel alloc] init];
    [headerText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerText setFont:STKFont(15)];
    [headerText setTextColor:[UIColor HATextColor]];
    [headerText setNumberOfLines:2];
    [cell addSubview:headerText];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_survey_sm"]];
    [iv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cell addSubview:iv];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[ht]-43-[iv(==16)]-14-|" options:0 metrics:nil views:@{@"ht": headerText, @"iv": iv}]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[ht]-0-|" options:0 metrics:nil views:@{@"ht": headerText}]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:iv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:iv attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:iv attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headerText attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [headerText setText:[NSString stringWithFormat:@"Please take this short survey from %@", self.survey.organization.name]];
    
    return cell;
}

- (UITableViewCell *)breadcrumb
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Breadcrumb"];
    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [cell setBackgroundColor:[UIColor clearColor]];
    UIView *wrapper = [[UIView alloc] init];
    [wrapper setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSMutableDictionary *bcs = [NSMutableDictionary dictionary];
    for (int i = 0; i != [self.survey.numberOfQuestions integerValue]; ++i) {
        BOOL active = (i + 1) <= self.questionNumber;
        UIView *v = [self breadcrumbIsActive:active];
        [wrapper addSubview:v];
        [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v": v}]];
        [bcs setObject:v forKey:[NSString stringWithFormat:@"v%u", i]];
    }
    
    NSArray *keys = [bcs allKeys];
    NSMutableString *formatString = [@"H:|-0-" mutableCopy];
    NSEnumerator *e = [keys reverseObjectEnumerator];
    for (NSString *obj in e) {
        [formatString appendFormat:@"[%@(==21)]", obj];
        if (obj != [keys objectAtIndex:0]) {
            [formatString appendString:@"-4-"];
        } else {
            [formatString appendString:@"-0-|"];
        }
    }
    
    UILabel *positionLabel = [[UILabel alloc] init];
    [positionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)self.questionNumber] attributes:@{NSFontAttributeName: STKBoldFont(15), NSForegroundColorAttributeName: [UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:1]}];
    NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"/%ld", (long)[self.survey.numberOfQuestions integerValue]] attributes:@{NSFontAttributeName: STKFont(15), NSForegroundColorAttributeName: [UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:0.5]}];
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithAttributedString:attString];
    [finalString appendAttributedString:attString2];
    [positionLabel setAttributedText:finalString];
    UILabel *currentNumber = [[UILabel alloc] init];
    [currentNumber setTranslatesAutoresizingMaskIntoConstraints:NO];
    [currentNumber setText:[NSString stringWithFormat:@"%ld", (long)self.questionNumber]];
    [currentNumber setFont:STKFont(36)];
    [currentNumber setTextColor:[UIColor HATextColor]];
    [currentNumber sizeToFit];
    [cell addSubview:currentNumber];
    
    
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:bcs]];
    [cell addSubview:wrapper];
    [cell addSubview:positionLabel];
    
    UITextView *questionView = [[UITextView alloc] init];
    [questionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [questionView setFont:STKBoldFont(15)];
    [questionView setTextColor:[UIColor HATextColor]];
    [questionView setEditable:NO];
    [questionView setScrollEnabled:NO];
    [questionView setText:[self.question text]];
    [questionView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.15f]];
    [questionView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [questionView.layer setBorderWidth:1.f];
    [questionView setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:questionView];
    
    /** CONSTRAINTS **/
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=8)-[w(==21)]-(<=27)-[cn]-(<=14)-[qv(>=35)]-(>=0)-|" options:0 metrics:nil views:@{@"w": wrapper, @"cn": currentNumber, @"qv": questionView}]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:currentNumber attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];

    [cell addConstraint:[NSLayoutConstraint constraintWithItem:wrapper attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[w]-16-[pl]" options:0 metrics:nil views:@{@"w":wrapper, @"pl": positionLabel}]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:positionLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:positionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-36-[qv]-36-|" options:0 metrics:nil views:@{@"qv": questionView}]];
    return cell;
}

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

- (UITableViewCell *)scaleCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Scale"];
    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [cell setBackgroundColor:[UIColor clearColor]];
    UILabel *disagree = [[UILabel alloc] init];
    [disagree setTranslatesAutoresizingMaskIntoConstraints:NO];
    [disagree setText:@"Strongly Disagree"];
    [disagree setFont:STKFont(15)];
    [disagree setTextColor:[UIColor HATextColor]];
    [cell addSubview:disagree];
    UILabel *agree = [[UILabel alloc] init];
    [agree setTranslatesAutoresizingMaskIntoConstraints:NO];
    [agree setText:@"Strongly Agree"];
    [agree setFont:STKFont(15)];
    [agree setTextColor:[UIColor HATextColor]];
    [cell addSubview:agree];
    
    UIView *wrapper = [[UIView alloc] init];
    [wrapper setTranslatesAutoresizingMaskIntoConstraints:NO];
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
        [wrapper addSubview:button];
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
        [wrapper addSubview:label];
        
        [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
        [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeBottom multiplier:1.f constant:20]];
        [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
      
  
    }
    self.valueButtons = [viewsA allValues];
    int wrapperMargin = self.question.scale.integerValue == 5?39:0;


    
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutA options:0 metrics:nil views:viewsA]];
    [cell addSubview:wrapper];
    
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[d(==20)]-13-[w(==77)]|" options:0 metrics:nil views:@{@"d": disagree, @"w": wrapper}]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[d]-85-[a]-8-|" options:0 metrics:nil views:@{@"d": disagree, @"a": agree}]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:agree attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:disagree attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    NSString *wrapperH = [NSString stringWithFormat:@"H:|-%u-[w]-%u-|", wrapperMargin, wrapperMargin];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:wrapperH options:0 metrics:nil views:@{@"w": wrapper}]];
    
    return cell;
}

- (UITableViewCell *)multipleCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Multiple"];
    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [cell setBackgroundColor:[UIColor clearColor]];
    NSMutableDictionary *rowKeys = [NSMutableDictionary dictionary];
    NSMutableString *formatString = [[NSMutableString alloc] initWithString:@"V:|-0-"];
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
        [cell addSubview:button];
        [cell addSubview:label];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[b(==24)]-10-[l]-0-|" options:0 metrics:nil views:@{@"b": button, @"l": label}]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        [formatString appendFormat:@"[%@(==24)]", key];
        if (option.order.integerValue != self.question.options.count) {
            [formatString appendString:@"-12-"];
        } else {
            [formatString appendString:@""];
        }
    }];
    self.valueButtons = [rowKeys allValues];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:rowKeys]];
    return cell;
}

- (UITableViewCell *)buttonCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Button"];
    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [cell setBackgroundColor:[UIColor clearColor]];
    UIButton *button = [[UIButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (self.questionNumber == self.survey.questions.count) {
        [button setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        [button setTitle:@"Next" forState:UIControlStateNormal];
    }
    [button setBackgroundColor:[UIColor colorWithRed:64.f/255.f green:86.f/255.f blue:152.f/255.f alpha:1.f]];
    [button addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[b(==44)]" options:0 metrics:nil views:@{@"b": button}]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-85-[b]-85-|" options:0 metrics:nil views:@{@"b": button}]];
    
    return cell;
}

@end
