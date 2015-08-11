//
//  HASurveyDashboardViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASurveyDashboardViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "HASurveyAvatarHeaderCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "STKUser.h"
#import "STKUserStore.h"
#import "STKOrgStatus.h"
#import "STKOrganization.h"
#import "HASurveyRankingCell.h"
#import "STKLeaderboardItem.h"
#import "STKLeaderBoardCell.h"
#import "STKProfileViewController.h"
#import "HACompletedSurveysViewController.h"

@interface HASurveyDashboardViewController ()<UITableViewDataSource, UITableViewDelegate, HASurveyRankingCellProtocol>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, strong) NSArray *leaders;
@property (nonatomic) long userPosition;
@property (nonatomic) long userPoints;
@property (nonatomic) long surveyCount;

@end

@implementation HASurveyDashboardViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
        [self.tabBarItem setTitle:@"Survey"];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_survey"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_survey_selected"]];
        self.leaders = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Survey";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshColor) name:@"UserDetailsUpdated" object:nil];
    
    [self.tableView registerClass:[HASurveyAvatarHeaderCell class] forCellReuseIdentifier:[HASurveyAvatarHeaderCell reuseIdentifier]];
    [self.tableView registerClass:[HASurveyRankingCell class] forCellReuseIdentifier:[HASurveyRankingCell reuseIdentifier]];
    [self.tableView registerClass:[STKLeaderBoardCell class] forCellReuseIdentifier:[STKLeaderBoardCell reuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.navigationItem setLeftBarButtonItem:[self menuBarButtonItem]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.user = [[STKUserStore store] currentUser];
    if (![self.user.type isEqualToString:@"institution_verified"]) {
        [self.user.organizations enumerateObjectsUsingBlock:^(STKOrgStatus *obj, BOOL *stop) {
            if ([obj.status isEqualToString:@"active"]) {
                self.organization = obj.organization;
            }
        }];
    }
    [self fetchLeaders];
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Configuration
- (void)setupViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0.f, 0.f, 0.f)];
    [self.view addSubview:self.tableView];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv":self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv":self.tableView}]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Actors

- (void)surveyCountTapped:(id)sender
{
    HACompletedSurveysViewController *hvc = [[HACompletedSurveysViewController alloc] init];
    [self.navigationController pushViewController:hvc animated:YES];
}

#pragma mark Workers

- (void)refreshColor
{
    [self handleUserUpdate];
    [self.tableView reloadData];
}

- (void)fetchLeaders
{
    if (self.organization) {
        NSArray *leaders = [[STKUserStore store] fetchLeaderboardForOrganization:self.organization completion:^(NSArray *leaders, NSError *err) {
            [self processLeaderboard:leaders];
        }];
        [self processLeaderboard:leaders];
    }
}

- (void)processLeaderboard:(NSArray *)leaders
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.leaders = [leaders sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"points" ascending:false]]];
        NSUInteger idx = [self.leaders indexOfObjectPassingTest:^BOOL(STKLeaderboardItem *obj, NSUInteger idx, BOOL *stop) {
            return [obj.userID isEqualToString:self.user.uniqueID];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (idx != NSNotFound) {
                self.userPosition = idx + 1;
                self.userPoints = [[[self.leaders objectAtIndex:idx] points] longValue];
                self.surveyCount = [[[self.leaders objectAtIndex:idx] surveys] longValue];
            }
            [self.tableView reloadData];
        });
        
    });
    
}

#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return self.leaders.count + 1;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self userAvatarCell];
    } else if (indexPath.section == 1) {
        return [self rankingCell];
    } else {
        if (indexPath.row == 0) {
            return [self rankingHeadCell];
        } else {
            return [self leaderboardCell:indexPath];
        }
    }
}


#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 49;
    } else if (indexPath.section == 1){
        return 187;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (indexPath.row > 0) {
            long index = indexPath.row - 1;
            STKLeaderboardItem *item = [self.leaders objectAtIndex:index];
            STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
            [pvc setProfile:item.user];
            [self.navigationController pushViewController:pvc animated:YES];
            
        }
    }
}


#pragma mark Cell Generation

- (UITableViewCell *)userAvatarCell
{
    HASurveyAvatarHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HASurveyAvatarHeaderCell reuseIdentifier]];
    NSString *orgShort = [self.organization.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    [cell.nameLabel setText:[NSString stringWithFormat:@"%@@%@", self.user.firstName, orgShort]];
    [cell.avatarView setUrlString:self.user.profilePhotoPath];
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    return cell;
    
}

- (UITableViewCell *)rankingCell
{
    HASurveyRankingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HASurveyRankingCell reuseIdentifier]];
    NSString *positionSuffix = @"";
    if (self.userPosition) {
        switch (self.userPosition) {
            case 1:
                positionSuffix = @"st";
                break;
            case 2:
                positionSuffix = @"nd";
                break;
            case 3:
                positionSuffix = @"rd";
                break;
            default:
                positionSuffix = @"th";
                break;
        }
    }
    NSString *ranking = self.userPosition?[NSString stringWithFormat:@"%ld%@", (long)self.userPosition, positionSuffix]:@"Unranked";
    [cell.rankingLabel setText:ranking];
    [cell.pointsLabel setText:[NSString stringWithFormat:@"%ld", self.userPoints]];
    [cell.surveysLabel setText:[NSString stringWithFormat:@"%ld", self.surveyCount]];
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    [cell setDelegate:self];
    return cell;
}

- (UITableViewCell *)rankingHeadCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RankHead"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RankHead"];
        [cell setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
        UILabel *textLabel = [[UILabel alloc] init];
        [textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [textLabel setText:@"Leaderboard"];
        [textLabel setFont:STKFont(18)];
        [textLabel setTextColor:[UIColor HATextColor]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:textLabel];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        [cell setSelectedBackgroundView:[[UIView alloc] init]];
    }
    return cell;
}

- (UITableViewCell *)leaderboardCell:(NSIndexPath *)idx
{
    STKLeaderboardItem *item = [self.leaders objectAtIndex:(idx.row - 1)];
    STKLeaderBoardCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[STKLeaderBoardCell reuseIdentifier]];
    [cell.nameLabel setText:item.user.name];
    [cell.avatarView setUrlString:item.user.profilePhotoPath];
    [cell.pointsLabel setText:[NSString stringWithFormat:@"%ld Pts", [item.points longValue]]];
    [cell setRanking:idx.row];
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    return cell;
}

@end
