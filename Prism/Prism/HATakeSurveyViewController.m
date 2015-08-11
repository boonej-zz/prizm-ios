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
#import "UITableViewCell+HAExtensions.h"
#import "HASurveyHeaderCell.h"
#import "HASurveyBreadcrumbCell.h"
#import "HASurveyScaleCell.h"
#import "HASurveyMultipleCell.h"

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
    [self.tableView registerClass:[HASurveyHeaderCell class] forCellReuseIdentifier:[HASurveyHeaderCell reuseIdentifier]];
    [self.tableView registerClass:[HASurveyBreadcrumbCell class] forCellReuseIdentifier:[HASurveyBreadcrumbCell reuseIdentifier]];
    [self.tableView registerClass:[HASurveyScaleCell class] forCellReuseIdentifier:[HASurveyScaleCell reuseIdentifier]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Button"];
    [self.tableView registerClass:[HASurveyMultipleCell class] forCellReuseIdentifier:[HASurveyMultipleCell reuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    
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
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
}

#pragma mark - Actors
- (void)scaleButtonTapped:(UIButton *)sender cell:(HASurveyScaleCell *)cell
{
    [cell.valueButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        if (button != sender) {
            [button setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.15]];
        }
    }];
    [sender setBackgroundColor:[UIColor colorWithRed:0.f/255.f green:187.f/255.f blue:74.f/255.f alpha:1.f]];
    self.selectedValue = sender.tag;
}

- (void)multipleButtonTapped:(UIButton *)sender cell:(HASurveyMultipleCell *)cell
{
    [cell.valueButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
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
    HASurveyHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HASurveyHeaderCell reuseIdentifier]];
    [cell.titleLabel setText:[NSString stringWithFormat:@"Please take this short survey from %@", self.survey.organization.name]];
    return cell;
}

- (UITableViewCell *)breadcrumb
{
    HASurveyBreadcrumbCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HASurveyBreadcrumbCell reuseIdentifier]];
    [cell setQuestionNumber:[self questionNumber]];
    [cell setSurvey:self.survey];
    return cell;
}

- (UITableViewCell *)scaleCell
{
    HASurveyScaleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HASurveyScaleCell reuseIdentifier]];
    [cell setQuestion:self.question];
    [cell setDelegate:self];
    
    return cell;
}

- (UITableViewCell *)multipleCell
{
    HASurveyMultipleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HASurveyMultipleCell reuseIdentifier]];
    [cell setQuestion:self.question];
    [cell setDelegate:self];
    return cell;
}

- (UITableViewCell *)buttonCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Button"];
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
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[b(==150)]" options:0 metrics:nil views:@{@"b": button}]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    return cell;
}

@end
