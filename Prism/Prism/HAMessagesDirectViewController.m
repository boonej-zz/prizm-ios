//
//  HAMessagesDirectViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/14/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessagesDirectViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "UITableViewCell+HAExtensions.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKOrganization.h"
#import "STKOrgStatus.h"
#import "STKGroup.h"
#import "HAPlainAvatarCell.h"
#import "HAMessagesViewController.h"
#import "STKNavigationButton.h"
#import "HAMessagesUserChooserViewController.h"

@interface HAMessagesDirectViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) NSArray *groups;

@property (nonatomic, getter=isLeader) BOOL leader;
@property (nonatomic, getter=isAdmin) BOOL admin;


@end

@implementation HAMessagesDirectViewController

- (instancetype)init
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
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[HAPlainAvatarCell class] forCellReuseIdentifier:[HAPlainAvatarCell reuseIdentifier]];
    [self.tableView setContentInset:UIEdgeInsetsMake(65, 0, 80, 0)];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)configureConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv(==v)]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView, @"v": self.view}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tv(==v)]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView, @"v": self.view}]];
    
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"@direct";
    self.members = [NSMutableArray array];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    [self.navigationItem setLeftBarButtonItem:bbi];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.user = [[STKUserStore store] currentUser];
   
    [self setUserList];
    if ([self isAdmin] || [self isLeader]) {
        STKNavigationButton *view = [[STKNavigationButton alloc] init];
        [view addTarget:self action:@selector(newMessage:) forControlEvents:UIControlEventTouchUpInside];
        [view setOffset:9];
        [view setImage:[UIImage imageNamed:@"btn_addcontent"]];
        [view setHighlightedImage:[UIImage imageNamed:@"btn_addcontent_active"]];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
        [self.navigationItem setRightBarButtonItem:bbi];
    }
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if (self.members && self.members.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}


#pragma mark Property Methods

- (void)setUser:(STKUser *)user
{
    _user = user;
    if (self.organization) {
        [self setPrivelegeLevelForUser:self.user organization:self.organization];
    }
}

- (void)setOrganization:(STKOrganization *)organization
{
    _organization = organization;
    if (self.user) {
        [self setPrivelegeLevelForUser:self.user organization:self.organization];
    }
}

#pragma mark Workers

- (void)setPrivelegeLevelForUser:(STKUser *)user organization:(STKOrganization *)organization
{
    if ([user.type isEqualToString:STKUserTypeInstitution]) {
        [self setAdmin:YES];
    } else {
        [user.organizations enumerateObjectsUsingBlock:^(STKOrgStatus *obj, BOOL *stop) {
            if ([obj.organization.uniqueID isEqualToString:organization.uniqueID]) {
                if ([obj.role isEqualToString:@"leader"]) {
                    [self setLeader:YES];
                }
                [self setGroups:[obj.groups allObjects]];
            }
        }];
    }
}

- (void)setUserList
{
    if ([self isLeader] || [self isAdmin] ) {
   
        self.members = [[[STKUserStore store] fetchMessagedUsers] mutableCopy];
        [self.tableView reloadData];
        
    } else {
        self.members = [[[STKUserStore store] fetchMessagedUsers] mutableCopy];
        if (! [self.members containsObject:self.organization.owner]) {
            [self.members addObject:self.organization.owner];
        }
        [[STKUserStore store] fetchMembersForOrganization:self.organization completion:^(NSArray *messages, NSError *err) {
            [self.groups enumerateObjectsUsingBlock:^(STKGroup *obj, NSUInteger idx, BOOL *stop) {
                if (obj.leader) {
                    if (![self.members containsObject:obj.leader] && ![obj.leader.uniqueID isEqualToString:self.user.uniqueID]) {
                        [self.members addObject:obj.leader];
                    }
                }
            }];
            [self.tableView reloadData];
        }];
        
    }
}

#pragma mark Actors

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)newMessage:(id)sender
{
    HAMessagesUserChooserViewController *ucc = [[HAMessagesUserChooserViewController alloc] initWithOrganization:self.organization];
    [self.navigationController pushViewController:ucc animated:YES];
}

#pragma mark Cell Creation
- (UITableViewCell *)avatarCellForIndex:(NSIndexPath *)ip
{
    HAPlainAvatarCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HAPlainAvatarCell reuseIdentifier]];
    STKUser *member = [self.members objectAtIndex:ip.row];
    [cell.nameLabel setText:member.name];
    [cell.avatarView setUrlString:member.profilePhotoPath];
    [cell.countLabel setText:[NSString stringWithFormat:@"%ld", member.unreadCount.longValue]];
    [cell.countView setHidden:(member.unreadCount.integerValue == 0)];
    return cell;
}

#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *u = [self.members objectAtIndex:indexPath.row];
    HAMessagesViewController *mvc = [[HAMessagesViewController alloc] initWithOrganization:self.organization group:nil user:u];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self avatarCellForIndex:indexPath];
}



@end
