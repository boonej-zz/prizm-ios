//
//  STKUserListViewController.m
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKUserListViewController.h"
#import "STKSearchProfileCell.h"
#import "STKUser.h"
#import "STKProfileViewController.h"

@interface STKUserListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STKUserListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    [[self tableView] reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
    [pvc setProfile:[[self users] objectAtIndex:[indexPath row]]];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self users] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *u = [[self users] objectAtIndex:[indexPath row]];
    STKSearchProfileCell *c = [STKSearchProfileCell cellForTableView:tableView target:self];
    
    [[c nameLabel] setText:[u name]];
    [[c avatarView] setUrlString:[u profilePhotoPath]];
    
    return c;
}


@end
