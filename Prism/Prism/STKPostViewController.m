//
//  STKPostViewController.m
//  Prism
//
//  Created by Joe Conway on 1/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPostViewController.h"
#import "STKHomeCell.h"
#import "STKPost.h"
#import "STKProfileViewController.h"
#import "STKLocationViewController.h"

@interface STKPostViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *commentFooterView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

- (IBAction)postComment:(id)sender;

@end

@implementation STKPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    return self;
}

- (IBAction)showLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKLocationViewController *lvc = [[STKLocationViewController alloc] init];
    [lvc setCoordinate:[[self post] coordinate]];
    [[self navigationController] pushViewController:lvc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];

    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setTableFooterView:[self commentFooterView]];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[self tableView] reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillAppear:(NSNotification *)note
{
    CGRect r = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, r.size.height, 0)];
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}


- (void)imageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)avatarTapped:(id)sender
{
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:[[self post] creatorProfile]];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 421;
    }
    
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    
    // Comments
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        STKHomeCell *c = [STKHomeCell cellForTableView:tableView target:self];
        [[c topInset] setConstant:0];
        [[c leftInset] setConstant:0];
        [[c rightInset] setConstant:0];
        if(![[[[c headerView] avatarButton] allTargets] containsObject:self])
            [[[c headerView] avatarButton] addTarget:self action:@selector(avatarTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [c populateWithPost:[self post]];
        
        return c;
    }
    
    return nil;
}

- (IBAction)postComment:(id)sender {
}
@end
