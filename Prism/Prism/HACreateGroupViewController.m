//
//  HACreateGroupViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 5/1/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKUserStore.h"
#import "HACreateGroupViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "HASearchMembersHeaderView.h"
#import "STKTextFieldCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "HALabelAccessoryTableViewCell.h"
#import "STKUserSelectCellTableViewCell.h"
#import "STKUser.h"
#import "STKOrgStatus.h"
#import "HATextFieldCell.h"
#import "HASelectLeaderControllerViewController.h"

@interface HACreateGroupViewController ()<UITableViewDataSource, UITableViewDelegate, HACellDelegateProtocol, HASearchMembersDelegate, HASelectLeaderProtocol>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSArray * settings;
@property (nonatomic, strong) NSMutableArray * settingsVals;
@property (nonatomic, strong) NSArray * members;
@property (nonatomic, strong) NSArray * filteredMembers;
@property (nonatomic, strong) NSMutableArray * selectedMembers;
@property (nonatomic, strong) IBOutlet UITableView *searchTableView;
@property (nonatomic, weak) IBOutlet HASearchMembersHeaderView *searchHeader;
@property (nonatomic, strong) NSString *selectedLeader;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupDescription;

@end

@implementation HACreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedMembers = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.searchTableView registerClass:[STKUserSelectCellTableViewCell class] forCellReuseIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[HATextFieldCell class] forCellReuseIdentifier:[HATextFieldCell reuseIdentifier]];
    [self.tableView registerClass:[HALabelAccessoryTableViewCell class] forCellReuseIdentifier:[HALabelAccessoryTableViewCell reuseIdentifier]];
    self.settingsVals = [@[@"", @"", @""] mutableCopy];
    self.settings = @[
                      @{@"field":@"Group Name",
                        @"cell":@"HATextFieldCell"},
                      @{@"field":@"Group Leader",
                        @"cell":@"HALabelAccessoryTableViewCell"},
                      @{@"field":@"Group Description",
                        @"cell":@"HATextFieldCell"}
                       ];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                             landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                          target:self action:@selector(back:)];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:bbi];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
    [self.navigationItem setRightBarButtonItem:self.doneButton];
    [self.doneButton setEnabled:NO];
    [self.navigationItem setTitle:@"Create"];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.searchTableView setBackgroundColor:[UIColor clearColor]];
    [self.searchHeader setDelegate:self];
    
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
//    [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0, 40.f, 0)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.members = [[STKUserStore store] getMembersForOrganization:self.organization group:nil];
    self.filteredMembers = [[NSArray alloc] initWithArray:self.members copyItems:NO];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done:(id)sender
{
    [[STKUserStore store] createGroup:self.groupName forOrganization:self.organization withDescription:self.groupDescription leader:self.selectedLeader member:self.selectedMembers completion:^(id data, NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"There was a problem creating your group. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        } else {
            [[STKUserStore store] fetchUserDetails:[[STKUserStore store] currentUser] additionalFields:nil completion:^(STKUser *u, NSError *err) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

#pragma mark Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1000) return self.settings.count;
    return self.filteredMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<HACellProtocol> *c = nil;
    if ([tableView tag] == 1000) {
        NSDictionary *setting = [self.settings objectAtIndex:indexPath.row];
        c = [tableView dequeueReusableCellWithIdentifier:[setting valueForKey:@"cell"]];
        [[c label] setText:[setting valueForKey:@"field"]];
        if ([c isKindOfClass:[HATextFieldCell class]]){
            [[(HATextFieldCell *)c textField ]setText:[self.settingsVals objectAtIndex:indexPath.row]];
            [(HATextFieldCell *)c setDelegate:self];
        }
    } else {
        STKOrgStatus *u = [self.filteredMembers objectAtIndex:indexPath.row];
        STKUserSelectCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
        [cell.avatarView setUrlString:[u.member profilePhotoPath]];
        [cell.label setText:[u.member name]];
        NSString *uniqueID = u.member.uniqueID;
        if ([self.selectedMembers indexOfObjectPassingTest:^BOOL(NSString* obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:uniqueID];
        }] != NSNotFound){
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        c = cell;
    }
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47.f;
}


- (void)didEndEditingCell:(UITableViewCell<HACellProtocol> *)cell
{
    NSString *value = [[(HATextFieldCell *)cell textField] text];
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    self.settingsVals[ip.row] = value;
    if (ip.row == 0) {
        self.groupName = value;
    } else if (ip.row == 2) {
        self.groupDescription = value;
    }
    if (self.groupName && self.groupDescription) {
        [self.doneButton setEnabled:YES];
    }
    [self.searchTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchTableView) {
        STKOrgStatus *u = [self.filteredMembers objectAtIndex:indexPath.row];
        NSString *uniqueID = u.member.uniqueID;
        if ([self.selectedMembers indexOfObjectPassingTest:^BOOL(NSString* obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:uniqueID];
        }] == NSNotFound){
            [self.selectedMembers addObject:uniqueID];
        }

    } else if (indexPath.row == 1) {
        HASelectLeaderControllerViewController *svc = [[HASelectLeaderControllerViewController alloc] initWithSelection:self.selectedLeader];
        [svc setMembers:[self members]];
        [svc setDelegate:self];
        [self.navigationController pushViewController:svc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchTableView) {
        STKOrgStatus *u = [self.filteredMembers objectAtIndex:indexPath.row];
        NSString *uniqueID = u.member.uniqueID;
        if ([self.selectedMembers indexOfObjectPassingTest:^BOOL(NSString* obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:uniqueID];
        }]!= NSNotFound){
            [self.selectedMembers removeObject:uniqueID];
        }
    }
}

- (void)didSelectLeader:(STKOrgStatus *)leader
{
    if (leader) {
        self.selectedLeader = leader.member.uniqueID;
    } else {
        leader = nil;
    }
}

#pragma mark Search Members Delegate;
- (void)searchTextChanged:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        self.filteredMembers = [[NSArray alloc] initWithArray:self.members copyItems:NO];
    } else {
        self.filteredMembers = [self.members filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"member.name CONTAINS[cd] %@", text]];
    }
    
    [self.searchTableView reloadData];

}

@end
