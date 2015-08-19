//
//  HAMessagesUserChooserViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/18/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessagesUserChooserViewController.h"
#import "STKOrganization.h"
#import "UIViewController+STKControllerItems.h"
#import "UITableViewCell+HAExtensions.h"
#import "HAPlainAvatarCell.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKOrgStatus.h"
#import "HASearchMembersHeaderView.h"
#import "HAMessagesViewController.h"

@interface HAMessagesUserChooserViewController ()<UITableViewDataSource, UITableViewDelegate, HASearchMembersDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSLayoutConstraint *tableViewBottomConstraint;

@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, strong) NSArray *visibleMembers;
@property (nonatomic, strong) NSArray *members;

@property (nonatomic, strong) HASearchMembersHeaderView *searchBar;

@end

@implementation HAMessagesUserChooserViewController

- (instancetype)initWithOrganization:(STKOrganization *)organization
{
    self = [super init];
    
    if (self) {
        _organization = organization;
        [self configureViews];
        [self configureConstraints];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.visibleMembers = @[];
    [self.tableView registerClass:[HAPlainAvatarCell class] forCellReuseIdentifier:[HAPlainAvatarCell reuseIdentifier]];
    [[STKUserStore store] fetchMembersForOrganization:self.organization completion:^(NSArray *members, NSError *err) {
        self.members = members;
        self.visibleMembers = self.members;
        [self.tableView reloadData];
    }];
    [self.tableView setContentInset:UIEdgeInsetsMake(0.f, 0, 80.f, 0)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.title = @"new@direct";
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:bbi];

   
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

#pragma mark Configuration

- (void)configureViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[HASearchMembersHeaderView alloc] init];
    [self.searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    self.tableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
    
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)configureConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[sb(==47)]-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView, @"sb": self.searchBar}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sb]-0-|" options:0 metrics:nil views:@{@"sb": self.searchBar}]];
}

#pragma mark Actors

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Cell Creation

- (UITableViewCell *)avatarCellForIndexPath:(NSIndexPath *)ip
{
    HAPlainAvatarCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HAPlainAvatarCell reuseIdentifier]];
    STKUser *user = [self.visibleMembers objectAtIndex:ip.row];
    [cell.nameLabel setText:user.name];
    [cell.avatarView setUrlString:user.profilePhotoPath];
    [cell.countView setHidden:YES];
    return cell;
}

#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *user = [self.visibleMembers objectAtIndex:indexPath.row];
    HAMessagesViewController *mvc = [[HAMessagesViewController alloc] initWithOrganization:self.organization group:nil user:user];
    [self addChildViewController:mvc];
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.view addSubview:mvc.view];
    self.title = [NSString stringWithFormat:@"@%@", user.name];
    
}


#pragma mark TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.visibleMembers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self avatarCellForIndexPath:indexPath];
}

#pragma mark Search Bar Delegate

- (void)searchTextChanged:(NSString *)text
{
    if (text.length > 0){
        self.visibleMembers = [_members filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", text]];
    } else {
        self.visibleMembers = self.members;
    }
    [self.tableView reloadData];
}


@end
