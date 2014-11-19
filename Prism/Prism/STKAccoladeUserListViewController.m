//
//  STKAccoladeUserListViewController.m
//  Prism
//
//  Created by Joe Conway on 5/29/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKAccoladeUserListViewController.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKSearchProfileCell.h"
#import "STKCreateAccoladeViewController.h"

@interface STKAccoladeUserListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *users;
@end

@implementation STKAccoladeUserListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];
    [[self tableView] setContentInset:UIEdgeInsetsMake(65, 0, 0, 0)];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:v];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

    [[STKUserStore store] fetchTrustsForUser:[[STKUserStore store] currentUser] fetchDescription:nil completion:^(NSArray *trusts, NSError *err) {
        [self setUsers:[trusts valueForKey:@"otherUser"]];
        [[self tableView] reloadData];
    }];
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *u = [[self users] objectAtIndex:[indexPath row]];
    STKCreateAccoladeViewController *avc = [[STKCreateAccoladeViewController alloc] init];
    [avc setUser:u];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
    [self presentViewController:nvc animated:YES completion:nil];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self users] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *u = [[self users] objectAtIndex:[indexPath row]];
    STKSearchProfileCell *c = [STKSearchProfileCell cellForTableView:tableView target:self];
    
    [[c nameLabel] setTextColor:[UIColor HATextColor]];
    [[c nameLabel] setText:[u name]];
    [[c avatarView] setUrlString:[u profilePhotoPath]];
    [[c followButton] setHidden:YES];
    [[c cancelTrustButton] setHidden:YES];
    [[c mailButton] setHidden:YES];
    
    [[c luminaryIcon] setHidden:![u isLuminary]];

    return c;
}

@end
