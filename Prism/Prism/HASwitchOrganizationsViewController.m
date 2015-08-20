//
//  HASwitchOrganizationsViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/20/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASwitchOrganizationsViewController.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKOrgStatus.h"
#import "STKOrganization.h"
#import "STKUserSelectCellTableViewCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "UIViewController+STKControllerItems.h"
#import "HAAccountSelectionCell.h"

@interface HASwitchOrganizationsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) NSArray *statuses;
@property (nonatomic, strong) STKOrganization *currentOrganization;

@end

@implementation HASwitchOrganizationsViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self configureViews];
        [self configureConstraints];
    }
    return self;
}

#pragma mark Configuration

- (void)configureViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)configureConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv(==v)]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView, @"v": self.view}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tv(==v)]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView, @"v": self.view}]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [[STKUserStore store] currentUser];
    self.statuses = @[];
    [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0, 0, 0)];
    [self.tableView registerClass:[STKUserSelectCellTableViewCell class] forCellReuseIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.currentOrganization = [[STKUserStore store] activeOrgForUser];
    self.title = @"Organizations";
    [[STKUserStore store] fetchUserOrgs:^(NSArray *organizations, NSError *err) {
        self.statuses = organizations;
        [self.tableView reloadData];
    }];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
    [self.navigationItem setLeftBarButtonItem:close];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)close:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKOrganization *org = [self.statuses objectAtIndex:indexPath.row];
    [[STKUserStore store] changeOrgForUser:org];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKOrganization *org = [self.statuses objectAtIndex:indexPath.row];
    HAAccountSelectionCell *cell = [HAAccountSelectionCell cellForTableView:tableView target:self];
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    [cell setAccount:org.owner];
    BOOL active = NO;
    if ([org.uniqueID isEqualToString:self.currentOrganization.uniqueID]) {
        active = YES;
    }
    UIImageView *di = active?[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_check_active"]]:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_check"]];
    [cell setAccessoryView:di];
    return cell;
}

@end
