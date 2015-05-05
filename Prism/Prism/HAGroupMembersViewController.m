//
//  HAGroupMembersViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 5/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAGroupMembersViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserSelectCellTableViewCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "STKGroup.h"
#import "STKUser.h"
#import "STKOrgStatus.h"
#import "STKUserStore.h"
#import "STKNavigationButton.h"
#import "STKOrganization.h"
#import "HASelectMemberViewController.h"

@interface HAGroupMembersViewController ()<UITableViewDataSource, UITableViewDelegate, HASelectMemberProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) STKUser *user;
@property (nonatomic, getter=isLeader) BOOL leader;

@end

@implementation HAGroupMembersViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0, 0, 0)];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addBackgroundImage];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": _tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
    [self addBlurViewWithHeight:64.f];
    self.user = [[STKUserStore store] currentUser];

    
}

- (void)addMember:(id)sender
{
    NSMutableArray *selections = [NSMutableArray array];
    NSArray *members = [[STKUserStore store] getMembersForOrganization:self.organization group:nil];
    [self.group.members enumerateObjectsUsingBlock:^(STKOrgStatus *obj, BOOL *stop) {
        [selections addObject:[obj.member uniqueID]];
    }];
    HASelectMemberViewController *mvc = [[HASelectMemberViewController alloc] initWithSelection:selections predicate:nil];
    [mvc setMembers:members];
    [mvc setDelegate:self];
    [mvc setTitle:@"Members"];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[STKUserSelectCellTableViewCell class] forCellReuseIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:bbi];
    self.title = @"Members";
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSSet *leaderArray = [self.user.organizations filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(STKOrgStatus *evaluatedObject, NSDictionary *bindings) {
        return [[[evaluatedObject organization] uniqueID] isEqualToString:self.organization.uniqueID] && [[evaluatedObject role] isEqualToString:@"leader"];
    }]];
    if (leaderArray.count > 0 || [self.user.type isEqualToString:@"institution_verified"]) {
        self.leader = YES;
    }
    if ([self isLeader] && self.group) {
        STKNavigationButton *view = [[STKNavigationButton alloc] init];
        [view addTarget:self action:@selector(addMember:) forControlEvents:UIControlEventTouchUpInside];
        [view setOffset:9];
        [view setImage:[UIImage imageNamed:@"btn_addcontent"]];
        [view setHighlightedImage:[UIImage imageNamed:@"btn_addcontent_active"]];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
        [self.navigationItem setRightBarButtonItem:bbi];
    }
    self.members = [[[STKUserStore store] getMembersForOrganization:self.organization group:self.group] mutableCopy];
    [self.tableView reloadData];
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

#pragma mark Select Member Protocol

- (void)finishedMakingSelections:(NSArray *)selections
{
    NSMutableArray *members = [NSMutableArray array];
    [selections enumerateObjectsUsingBlock:^(STKOrgStatus *obj, NSUInteger idx, BOOL *stop) {
        [members addObject:obj.member.uniqueID];
    }];
    [[STKUserStore store] editMembers:members forGroup:self.group completion:^(id data, NSError *err) {
        [[STKUserStore store] fetchUserDetails:self.user additionalFields:nil completion:^(STKUser *u, NSError *err) {
        }];
        self.members = [[[STKUserStore store] getMembersForOrganization:self.organization group:self.group] mutableCopy];
        [self.tableView reloadData];
        
        
    }];
}

#pragma mark TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static UIImage *yellowWarningImage = nil;
    if (!yellowWarningImage) {
        yellowWarningImage = [UIImage imageNamed:@"warning_yellow"];
    }
    STKUserSelectCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
    STKUser *member = [(STKOrgStatus *)[self.members objectAtIndex:indexPath.row] member];
    [cell.label setText:member.name];
    [cell.avatarView setUrlString:member.profilePhotoPath];
    [cell setAccessoryView:[[UIImageView alloc] initWithImage:yellowWarningImage]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47.f;
}

@end
