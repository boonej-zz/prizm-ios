//
//  STKUserPostListViewController.m
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKUserPostListViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTriImageCell.h"
#import "STKResolvingImageView.h"
#import "STKPost.h"

@interface STKUserPostListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *filterBar;

@end

@implementation STKUserPostListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        
    }
    return self;
}

- (void)setPosts:(NSArray *)posts
{
    _posts = posts;
    [[self tableView] reloadData];
}

- (CGRect)rectForPostAtIndex:(int)idx inTableView:(UITableView *)tv
{
    int row = idx / 3;
    int offset = idx % 3;
    
    STKTriImageCell *c = (STKTriImageCell *)[tv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
    CGRect r = CGRectZero;
    if(offset == 0)
        r = [[c leftImageView] frame];
    else if(offset == 1)
        r = [[c centerImageView] frame];
    else if(offset == 2)
        r = [[c rightImageView] frame];
    
    return [[self view] convertRect:r fromView:c];
}

- (void)showPostAtIndex:(int)idx
{
    [[self view] endEditing:YES];
    
    if(idx < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:idx];
        [[self menuController] transitionToPost:p
                                       fromRect:[self rectForPostAtIndex:idx inTableView:[self tableView]]
                               inViewController:self
                                       animated:YES];
    }
}

- (void)leftImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    int row = [ip row];
    int itemIndex = row * 3;
    [self showPostAtIndex:itemIndex];
}

- (void)centerImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    int row = [ip row];
    int itemIndex = row * 3 + 1;
    [self showPostAtIndex:itemIndex];
    
}

- (void)rightImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    int row = [ip row];
    int itemIndex = row * 3 + 2;
    [self showPostAtIndex:itemIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setRowHeight:106];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] setContentInset:UIEdgeInsetsMake([[self filterBar] bounds].size.height + [[self filterBar] frame].origin.y, 0, 0, 0)];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[self posts] count] % 3 > 0)
        return [[self posts] count] / 3 + 1;
    return [[self posts] count] / 3;
}

- (void)populateTriImageCell:(STKTriImageCell *)c forRow:(int)row inArray:(NSArray *)posts
{
    int arrayIndex = row * 3;
    
    if(arrayIndex + 0 < [posts count]) {
        STKPost *p = [posts objectAtIndex:arrayIndex + 0];
        [[c leftImageView] setUrlString:[p imageURLString]];
    } else {
        [[c leftImageView] setUrlString:nil];
    }
    if(arrayIndex + 1 < [posts count]) {
        STKPost *p = [posts objectAtIndex:arrayIndex + 1];
        [[c centerImageView] setUrlString:[p imageURLString]];
    } else {
        [[c centerImageView] setUrlString:nil];
    }
    
    if(arrayIndex + 2 < [posts count]) {
        STKPost *p = [posts objectAtIndex:arrayIndex + 2];
        [[c rightImageView] setUrlString:[p imageURLString]];
    } else {
        [[c rightImageView] setUrlString:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:self];
        [self populateTriImageCell:c forRow:(int)[indexPath row] inArray:[self posts]];
        
        return c;
}

@end