//
//  STKActivityViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKActivityViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKActivityCell.h"
#import "STKUserStore.h"
#import "STKActivityItem.h"

@interface STKActivityViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) NSArray *items;

@end

@implementation STKActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_notification"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_notification_selected"]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
    [[self tableView] setSeparatorColor:[UIColor colorWithWhite:1 alpha:0.5]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[STKUserStore store] fetchActivityForCurrentUser:^(NSArray *activity, NSError *error, BOOL moreComing) {
        if(!error) {
            _items = activity;
            [[self tableView] reloadData];
        }
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self items] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKActivityCell *cell = [STKActivityCell cellForTableView:tableView target:self];
    STKActivityItem *i = [[self items] objectAtIndex:[indexPath row]];
    
    [[cell profileImageView] setUrlString:[i profileImageURLString]];
    [[cell recentIndicatorImageView] setHidden:![i recent]];
    [[cell nameLabel] setText:[i userName]];
    [[cell activityTypeLabel] setText:[STKActivityItem stringForActivityItemType:[i type]]];
    [[cell imageReferenceView] setUrlString:[i referenceImageURLString]];
    
    
    return cell;
}

@end
