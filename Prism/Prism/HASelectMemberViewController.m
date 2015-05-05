//
//  HASelectLeaderControllerViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 5/3/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASelectMemberViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserSelectCellTableViewCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "STKOrgStatus.h"
#import "HASearchMembersHeaderView.h"
#import "STKUser.h"

@interface HASelectMemberViewController ()<UITableViewDataSource, UITableViewDelegate, HASearchMembersDelegate>

@property (nonatomic, strong)  UITableView *tableView;
@property (nonatomic, strong) NSArray *filteredMembers;
@property (nonatomic, strong) id selected;
@property (nonatomic, getter=hasEdits) BOOL edits;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) HASearchMembersHeaderView *searchBar;


@end

@implementation HASelectMemberViewController

- (id)initWithSelection:(id)selection predicate:(NSPredicate *)predicate
{
    self = [super init];
    if (self) {
        self.selected = selection;
        self.predicate = predicate;
        self.tableView = [[UITableView alloc] init];
        [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:self.tableView];
        self.searchBar = [[HASearchMembersHeaderView alloc] init];
        [self.searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.searchBar.delegate = self;
        [self.view addSubview:self.searchBar];
        [self setupConstraints];
    }
    return  self;
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[sb(==47)]-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView, @"sb": self.searchBar}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sb]-0-|" options:0 metrics:nil views:@{@"sb": self.searchBar}]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.selections = [NSMutableArray array];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerClass:[STKUserSelectCellTableViewCell class] forCellReuseIdentifier:[STKUserSelectCellTableViewCell reuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 47.f, 0)];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:bbi];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
    if ([self.selected isKindOfClass:[NSArray class]]) {
        [self.tableView setAllowsMultipleSelection:YES];
    }
}

- (void)back:(id)sender
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(finishedMakingSelections:)]){
            [self.delegate finishedMakingSelections:[self.selections copy]];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMembers:(NSArray *)members
{
    _members = members;
    if (self.predicate) {
        _members = [_members filteredArrayUsingPredicate:self.predicate];
    }
    _filteredMembers = _members;
    [self.tableView reloadData];
}

- (void)searchTextChanged:(NSString *)text
{
    if (text.length > 0){
        _filteredMembers = [_members filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"member.name CONTAINS[cd] %@", text]];
    } else {
        _filteredMembers = _members;
    }
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
    if (self.selected) {
        if ([self.selected isKindOfClass:[NSString class]]) {
            if ([self.selected isEqualToString:uniqueID]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        } else if ([self.selected isKindOfClass:[NSArray class]]) {
            if ([self.selected indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isEqualToString:uniqueID]) {
                    return YES;
                    *stop = YES;
                }
                return NO;
            }] != NSNotFound) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self.selections addObject:o];
            }
        }
    }
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.edits = YES;
    STKOrgStatus *status = [self.filteredMembers objectAtIndex:indexPath.row];
    self.selected = status.member.uniqueID;
    [self.selections addObject:status];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didSelectMember:)]) {
            [self.delegate didSelectMember:status];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.edits = YES;
    STKOrgStatus *status = [self.filteredMembers objectAtIndex:indexPath.row];
    self.selected = nil;
    [self.selections removeObject:status];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didSelectMember:)]) {
            [self.delegate didSelectMember:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47.f;
}


@end
