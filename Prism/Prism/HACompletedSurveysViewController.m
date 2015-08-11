//
//  HACompletedSurveysViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HACompletedSurveysViewController.h"
#import "STKSurvey.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "UIViewController+STKControllerItems.h"
#import "HAUserSurveyHeaderCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "HAUserSurveyCell.h"

@interface HACompletedSurveysViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) NSArray *surveys;

@end

@implementation HACompletedSurveysViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.surveys = @[];
    self.title = @"Surveys";
    self.user = [[STKUserStore store] currentUser];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setContentInset:UIEdgeInsetsMake(64.f, 0, 0, 0)];
    [self.tableView registerClass:[HAUserSurveyHeaderCell class] forCellReuseIdentifier:[HAUserSurveyHeaderCell reuseIdentifier]];
    [self.tableView registerClass:[HAUserSurveyCell class] forCellReuseIdentifier:[HAUserSurveyCell reuseIdentifier]];
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [self.navigationItem setLeftBarButtonItem:bbi];
    [self fetchCompletedSurveys];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration
- (void)setupViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
}

#pragma mark - Actors

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Workers
- (void)fetchCompletedSurveys
{
    [[STKUserStore store] fetchCompletedSurveysForUser:self.user completion:^(NSArray *surveys, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.surveys = surveys;
            [self.tableView reloadData];
        });
        
    }];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.surveys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self surveyCell:indexPath];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

#pragma mark - Cell Generation

- (UITableViewCell *)headerCell
{
    HAUserSurveyHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HAUserSurveyHeaderCell reuseIdentifier]];
    return cell;
}

- (UITableViewCell *)surveyCell:(NSIndexPath *)ip
{
    HAUserSurveyCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HAUserSurveyCell reuseIdentifier]];
    STKSurvey *survey = [self.surveys objectAtIndex:ip.row];
    [cell.titleLabel setText:survey.name];
    [cell.rankLabel setText:[NSString stringWithFormat:@"%@", survey.rank]];
    NSString *duration = survey.duration?survey.duration:@"-";
    [cell.durationLabel setText:duration];
    [cell.pointsLabel setText:[NSString stringWithFormat:@"%@", survey.points]];
    return cell;
    
}
@end
