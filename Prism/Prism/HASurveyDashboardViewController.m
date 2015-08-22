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
#import "STKSurvey.h"
#import "STKQuestion.h"
#import "STKAnswer.h"
#import "CorePlot-CocoaTouch.h"
#import "HABarChartCell.h"
#import "HARespondentCell.h"
#import "STKUserTarget.h"
#import "HASegmentedCell.h"

@interface HASurveyDashboardViewController ()<UITableViewDataSource, UITableViewDelegate, HASurveyRankingCellProtocol>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, strong) NSArray *leaders;
@property (nonatomic) long userPosition;
@property (nonatomic) long userPoints;
@property (nonatomic) long surveyCount;
@property (nonatomic) BOOL isInstitution;
@property (nonatomic, strong) NSArray *respondants;
@property (nonatomic, strong) NSArray *nonRespondants;
@property (nonatomic, strong) NSMutableDictionary *respondantTimes;
@property (nonatomic, strong) NSMutableDictionary *responsesByDate;
@property (nonatomic) BOOL showingResponders;


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
    self.showingResponders = YES;
    self.title = @"Survey";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshColor) name:@"UserDetailsUpdated" object:nil];
    
    [self.tableView registerClass:[HASurveyAvatarHeaderCell class] forCellReuseIdentifier:[HASurveyAvatarHeaderCell reuseIdentifier]];
    [self.tableView registerClass:[HASurveyRankingCell class] forCellReuseIdentifier:[HASurveyRankingCell reuseIdentifier]];
    [self.tableView registerClass:[STKLeaderBoardCell class] forCellReuseIdentifier:[STKLeaderBoardCell reuseIdentifier]];
    [self.tableView registerClass:[HABarChartCell class] forCellReuseIdentifier:[HABarChartCell reuseIdentifier]];
    [self.tableView registerClass:[HARespondentCell class] forCellReuseIdentifier:[HARespondentCell reuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.navigationItem setLeftBarButtonItem:[self menuBarButtonItem]];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.user = [[STKUserStore store] currentUser];
    self.isInstitution = [self.user.type isEqualToString:@"institution_verified"];
    if (![self.user.type isEqualToString:@"institution_verified"]) {
        self.organization = [[STKUserStore store] activeOrgForUser];
//        [self.user.organizations enumerateObjectsUsingBlock:^(STKOrgStatus *obj, BOOL *stop) {
//            if ([obj.status isEqualToString:@"active"]) {
//                self.organization = obj.organization;
//            }
//        }];
        self.leaders = @[];
        [self fetchLeaders];
        [self.tableView reloadData];
    } else {
        [[STKUserStore store] fetchUserOrgs:^(NSArray *organizations, NSError *err) {
            if (organizations.count > 0) {
                self.organization = [organizations objectAtIndex:0];
                [self fetchLatestSurvey];
            }
        }];
    }
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menuWillAppear:(BOOL)animated
{
    [[self navigationItem] setRightBarButtonItem:[self switchGroupItem]];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self navigationItem] setRightBarButtonItem:nil];
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
    [hvc setOrganization:self.organization];
    [self.navigationController pushViewController:hvc animated:YES];
}

- (void)segmentedControlChanged:(UISegmentedControl *)control
{
    if (control.selectedSegmentIndex == 0) {
        self.showingResponders = YES;
    } else {
        self.showingResponders = NO;
    }
    [self.tableView reloadData];
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

- (void)fetchLatestSurvey
{
    if (self.organization) {
        [[STKUserStore store] fetchLatestSurveyForOrganization:self.organization completion:^(STKSurvey *survey, NSError *err) {
            [self processSurvey:survey];
        }];
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
            } else {
                self.userPoints = 0;
                self.surveyCount = 0;
            }
            [self.tableView reloadData];
        });
        
    });
    
}

- (void)processSurvey:(STKSurvey *)survey
{
    self.respondants = [NSMutableArray array];
    self.nonRespondants = [NSMutableArray array];
    self.responsesByDate = [NSMutableDictionary dictionary];
    NSMutableDictionary *r = [NSMutableDictionary dictionary];
    NSMutableDictionary *nr = [NSMutableDictionary dictionary];
    if (survey && [survey isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)survey count] > 0) {
            survey = [(NSArray *)survey objectAtIndex:0];
        }
    }
    if (survey) {
        [survey.targeted enumerateObjectsUsingBlock:^(STKUserTarget *target, BOOL *stop) {
            HARespondentResult *res = [[HARespondentResult alloc] init];
            [res setUser:target.user];
            __block BOOL present = NO;
            [survey.completed enumerateObjectsUsingBlock:^(STKUser *complete, BOOL *stopIt) {
                if ([[complete uniqueID] isEqualToString:target.user.uniqueID]) {
                    present = YES;
                    *stopIt = YES;
                }
            }];
            if (present) {
                [r setObject:res forKey:target.user.uniqueID];
            } else {
                [nr setObject:res forKey:target.user.uniqueID];
            }
        }];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"M/d"];
        
        NSArray *sortedAnswers = [[[[survey.questions allObjects] lastObject] answers] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO]]];
        NSDate *lastDate = [sortedAnswers count] > 0?[[sortedAnswers objectAtIndex:0] createDate ]:[NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comp = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                        fromDate:lastDate];
        [comp setDay:(comp.day - 1)];
        NSDate *oneDay = [cal dateFromComponents:comp];
        [comp setDay:(comp.day - 1)];
        NSDate *twoDay = [cal dateFromComponents:comp];
        NSArray *keys = @[[df stringFromDate:twoDay], [df stringFromDate:oneDay], [df stringFromDate:lastDate]];
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.responsesByDate setObject:@0 forKey:obj];
        }];
        [[[[survey.questions allObjects] lastObject] answers] enumerateObjectsUsingBlock:^(STKAnswer *obj, BOOL *stop) {
            if ([r objectForKey:obj.user.uniqueID]) {
                [(HARespondentResult *)[r objectForKey:obj.user.uniqueID] setCompleteDate:obj.createDate];
            }
            NSString *key = [df stringFromDate:obj.createDate];
            if ([self.responsesByDate objectForKey:key]) {
                int count = [[self.responsesByDate objectForKey:key] intValue];
                count += 1;
                [self.responsesByDate setObject:[NSNumber numberWithInt:count] forKey:key];
            }
        }];
        [[[[survey.questions allObjects] objectAtIndex:0] answers] enumerateObjectsUsingBlock:^(STKAnswer *obj, BOOL *stop) {
            if ([r objectForKey:obj.user.uniqueID]) {
                [(HARespondentResult *)[r objectForKey:obj.user.uniqueID] setStartDate:obj.createDate];
            }
        }];
        self.respondants = [r allValues];
        self.nonRespondants = [nr allValues];
        self.showingResponders = YES;
        [self.tableView reloadData];
    }
}

#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isInstitution) {
        if (section == 0) {
            return 2;
        } else if (section == 1) {
            if (self.showingResponders) {
                return self.respondants.count;
            }
            return self.nonRespondants.count;
        }
    } else {
        if (section == 2) {
//            NSLog(@"Returning %lu rows for section 2.", self.leaders.count + 1);
            return self.leaders.count + 1;
        }
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isInstitution]) {
        return 2;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isInstitution]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                return [self graphCell];
            }
            return [self summaryHeaderCell];
        } else if (indexPath.section == 1) {
            return [self respondentCellAtIndexPath:indexPath];
        }
        return [self summaryHeaderCell];
    } else {
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
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.isInstitution && section == 1) {
        NSString *title1 = [NSString stringWithFormat:@"Respondents %lu", (unsigned long)self.respondants.count];
        NSString *title2 = [NSString stringWithFormat:@"Non-Respondents %lu", (unsigned long)self.nonRespondants.count];

        HASegmentedCell *segCell = [[HASegmentedCell alloc] initWithItems:@[title1, title2]];
        CGFloat width = (self.view.frame.size.width / 2) + 10;
        [segCell.segmentedControl setWidth:width forSegmentAtIndex:0];
        [segCell.segmentedControl setWidth:width forSegmentAtIndex:1];
        if (self.showingResponders) {
            [segCell.segmentedControl setSelectedSegmentIndex:0];
        } else {
            [segCell.segmentedControl setSelectedSegmentIndex:1];
        }
        [segCell.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];

        return segCell;
    }
    return nil;
}


#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isInstitution]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                return 228;
            }
            return 58;
        }
        return 50;
        
    } else {
        if (indexPath.section == 0) {
            return 49;
        } else if (indexPath.section == 1){
            return 187;
        } else {
            return 44;
        }
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
    } else if (indexPath.section == 1 && self.isInstitution) {
        HARespondentResult *result = nil;
        if (self.showingResponders) {
            result = [self.respondants objectAtIndex:indexPath.row];
        } else {
            result = [self.nonRespondants objectAtIndex:indexPath.row];
        }
        STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
        [pvc setProfile:result.user];
        [self.navigationController pushViewController:pvc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isInstitution && section == 1) {
        return 25;
    }
    return 0;
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

- (UITableViewCell *)summaryHeaderCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"summaryHeaderCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"summaryHeaderCell"];
        [cell setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:@"Summary"];
        [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [titleLabel setFont:STKFont(15)];
        [titleLabel setTextColor:[UIColor colorWithRed:254.f/255.f green:254.f/255.f blue:254.f/255.f alpha:1.f]];
        [titleLabel sizeToFit];
        [cell addSubview:titleLabel];
        [cell setSelectedBackgroundView:[[UIView alloc] init]];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_summary"]];
        [image setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell addSubview:image];
        
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[iv(==14)]-9-[tl]" options:0 metrics:nil views:@{@"iv": image, @"tl": titleLabel}]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:image attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:image attribute:NSLayoutAttributeWidth multiplier:1.f constant:2.f]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:image attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        CALayer *bottomBorder = [CALayer layer];
        
        bottomBorder.frame = CGRectMake(0.0f, 58.0f, self.tableView.frame.size.width, 1.0f);
        
        bottomBorder.backgroundColor = [UIColor colorWithRed:198.f/255.f green:200.f/255.f blue:204.f/255.f alpha:0.4f].CGColor;
        
        [cell.layer addSublayer:bottomBorder];

    }
    return cell;
}

- (UITableViewCell *)graphCell
{
    HABarChartCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HABarChartCell reuseIdentifier]];
//    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setPlotData:self.responsesByDate];
    return cell;
}

- (UITableViewCell *)respondentCellAtIndexPath:(NSIndexPath *)ip
{
    HARespondentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HARespondentCell reuseIdentifier]];
    HARespondentResult *result = nil;
    if (self.showingResponders) {
        result = [self.respondants objectAtIndex:ip.row];
    } else {
        result = [self.nonRespondants objectAtIndex:ip.row];
    }
    [cell setResult:result];
    return cell;
}

@end
