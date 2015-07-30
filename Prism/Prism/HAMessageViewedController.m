//
//  HAMessageViewedController.m
//  Prizm
//
//  Created by Jonathan Boone on 7/30/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessageViewedController.h"
#import "STKSegmentedControl.h"
#import "STKMessage.h"
#import "STKGroup.h"
#import "STKOrgStatus.h"
#import "STKOrganization.h"
#import "STKUser.h"
#import "STKSearchProfileCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "STKUserStore.h"
#import "STKOrgStatus.h"
#import "STKProfileViewController.h"
#import "UIViewController+STKControllerItems.h"

@interface HAMessageViewedController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) STKSegmentedControl *segmentedControl;
@property (nonatomic, strong) NSArray *notViewed;
@property (nonatomic, strong) NSArray *viewed;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HAMessageViewedController

- (id)init {
    self = [super init];
    if (self) {
        [self configureViews];
        [self setupConstraints];
    }
    return self;
}

- (void)configureViews {
    self.segmentedControl = [[STKSegmentedControl alloc] initWithItems:@[@"Viewed", @"Not Viewed"]];
    [self.segmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)setupConstraints {
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[sc(==46)]-0-[tv]-0-|" options:0 metrics:nil views:@{@"sc": self.segmentedControl, @"tv": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sc]-0-|" options:0 metrics:nil views:@{@"sc": self.segmentedControl}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                 landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                              target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];
    [self.navigationItem setHidesBackButton:YES];
    
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    [self.tableView registerNib:[UINib nibWithNibName:[STKSearchProfileCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[STKSearchProfileCell reuseIdentifier]];
    [self addBlurViewWithHeight:110.f];
    self.title = @"Viewers";

    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentedControlChanged:(STKSegmentedControl *)segmentedControl
{
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMessage:(STKMessage *)message
{
    _message = message;
    self.viewed = [[message.read allObjects] sortedArrayUsingComparator:^NSComparisonResult(STKUser *obj1, STKUser *obj2) {
        return [obj1.name compare:obj2.name];
    }];
}

- (void)setMembers:(NSArray *)members
{
    NSMutableArray *notViewed = [NSMutableArray array];
    
    [members  enumerateObjectsUsingBlock:^(STKOrgStatus *member, NSUInteger idx, BOOL *stop) {
        __block BOOL valid = YES;
        [self.viewed enumerateObjectsUsingBlock:^(STKUser *viewer, NSUInteger idx, BOOL *stop) {
            if ([viewer.uniqueID isEqualToString:member.member.uniqueID]) {
                valid = NO;
                *stop = YES;
            }
        }];
        if (valid) {
            [notViewed addObject:member.member];
        }
    }];
    self.notViewed = [notViewed copy];
    notViewed = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return self.viewed.count;
    } else {
        return self.notViewed.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *user = nil;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        user = [self.viewed objectAtIndex:indexPath.row];
    } else {
        user = [self.notViewed objectAtIndex:indexPath.row];
    }
    STKSearchProfileCell *cell = [STKSearchProfileCell cellForTableView:tableView target:self];
    [[cell nameLabel] setTextColor:[UIColor HATextColor]];
    [[cell nameLabel] setText:[user name]];
    [[cell avatarView] setUrlString:[user profilePhotoPath]];
    [[cell cancelTrustButton] setHidden:YES];
    [[cell mailButton] setHidden:YES];
    cell.backgroundColor = [UIColor clearColor];
    [[cell luminaryIcon] setHidden:![user isLuminary]];
    [[cell ambassadorIcon] setHidden:![user isAmbassador]];
    [cell.underlayView setHidden:NO];
    if([user isEqual:[[STKUserStore store] currentUser]]) {
        [[cell followButton] setHidden:YES];
    } else {
        [[cell followButton] setHidden:NO];
        if([[[STKUserStore store] currentUser] isFollowingUser:user]) {
            [[cell followButton] setSelected:YES];
        } else {
            [[cell followButton] setSelected:NO];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}

#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *user = nil;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        user = [self.viewed objectAtIndex:indexPath.row];
    } else {
        user = [self.notViewed objectAtIndex:indexPath.row];
    }
    STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
    [pvc setProfile:user];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)toggleFollow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *u = nil;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        u = [self.viewed objectAtIndex:ip.row];
    } else {
        u = [self.notViewed objectAtIndex:ip.row];
    }
    if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[STKUserStore store] unfollowUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self tableView] cellForRowAtIndexPath:ip] followButton] setSelected:NO];
            } else {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }];
    } else {
        [[STKUserStore store] followUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self tableView] cellForRowAtIndexPath:ip] followButton] setSelected:YES];
            } else {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }];
    }
    
}

@end
