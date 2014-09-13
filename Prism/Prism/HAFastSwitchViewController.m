//
//  HAFastSwitchViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 9/12/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAFastSwitchViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "HAAccountSelectionCell.h"
#import "STKLoginViewController.h"

@interface HAFastSwitchViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *users;

@end

@implementation HAFastSwitchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.users = @[];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [self loadData];
    self.title = @"Switch";
    [self layoutViews];
    [self.tableView setContentInset:UIEdgeInsetsMake(4, 0, 0, 0)];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData
{
    self.users = [[STKUserStore store] loggedInUsers];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutViews
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [[b titleLabel] setFont:STKFont(18)];
    [[b titleLabel] setTextColor:STKTextColor];
    [b addTarget:self action:@selector(showSignIn:) forControlEvents:UIControlEventTouchUpInside];
    [b setBackgroundImage:[UIImage imageNamed:@"btn_lg"] forState:UIControlStateNormal];
    [b setTitle:@"Add Profile" forState:UIControlStateNormal];
    [b setFrame:CGRectMake(10, 50, 300, 51)];
   

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    [bottomView addSubview:b];
    [self.tableView setTableFooterView:bottomView];
}

- (void)showSignIn:(id)sender
{
    STKLoginViewController *lvc = [[STKLoginViewController alloc] init];
//    [self presentViewController:lvc animated:YES completion:nil];
    [self.navigationController pushViewController:lvc animated:NO];
}


- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *obj = [self.users objectAtIndex:indexPath.row];
    HAAccountSelectionCell *cell = [HAAccountSelectionCell cellForTableView:tableView target:self];
    [cell setAccount:[obj valueForKey:@"user"]];
    UIImageView *di = [[obj valueForKey:@"active"] boolValue]?[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_check_active"]]:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_check"]];
    [cell setAccessoryView:di];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *user = [[self.users objectAtIndex:indexPath.row] valueForKey:@"user"];

    [[STKUserStore store] switchToUser:user];
    [self loadData];
    [self.menuController recreateAllViewControllers];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
