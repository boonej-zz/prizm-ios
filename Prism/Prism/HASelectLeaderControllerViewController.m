//
//  HASelectLeaderControllerViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 5/3/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASelectLeaderControllerViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserSelectCellTableViewCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "STKOrgStatus.h"
#import "STKUser.h"

@interface HASelectLeaderControllerViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *filteredMembers;
@property (nonatomic, strong) NSString *selected;

@end

@implementation HASelectLeaderControllerViewController

- (id)initWithSelection:(NSString *)selection
{
    self = [super init];
    if (self) {
        self.selected = selection;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerClass:[STKUserSelectCellTableViewCell class] forCellReuseIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0, 40.f, 0)];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:bbi];
    [self.navigationItem setTitle:@"Leader"];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMembers:(NSArray *)members
{
    _members = members;
    _filteredMembers = [_members filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"role == %@", @"leader"]];
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

#pragma mark UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredMembers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUserSelectCellTableViewCell *c = [self.tableView dequeueReusableCellWithIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
    STKOrgStatus *o = [self.filteredMembers objectAtIndex:indexPath.row];
    [c.avatarView setUrlString:[o.member profilePhotoPath]];
    [c.label setText:[o.member name]];
    NSString *uniqueID = o.member.uniqueID;
    if (self.selected && [self.selected isEqualToString:uniqueID]){
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKOrgStatus *status = [self.filteredMembers objectAtIndex:indexPath.row];
    self.selected = status.member.uniqueID;
    if (self.delegate) {
        [self.delegate didSelectLeader:status];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selected = nil;
    if (self.delegate) {
        [self.delegate didSelectLeader:nil];
    }
}


@end
