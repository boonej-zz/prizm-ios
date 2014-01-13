//
//  STKProfileViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKProfileViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"
#import "STKProfileCell.h"
#import "STKCountView.h"
#import "STKUser.h"
#import "STKInitialProfileStatisticsCell.h"

@interface STKProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STKProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_user"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_user_selected"]];

    }
    return self;
}

- (IBAction)temporaryLogout:(id)sender
{
    [[self menuController] logout];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
}

- (float)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 246;
    } else if([indexPath section] == 1) {
        return 213;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0 || [indexPath section] == 1) {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 246;
    } else if([indexPath section] == 1) {
        return 213;
    }
    return 44;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        STKProfileCell *c = [STKProfileCell cellForTableView:tableView target:self];
        
        STKUser *u = [[STKUserStore store] currentUser];
        [[c nameLabel] setText:[NSString stringWithFormat:@"%@ %@", [u firstName], [u lastName]]];
        if([u city])
            [[c locationLabel] setText:[u city]];
        else
            [[c locationLabel] setText:@""];
        
        return c;
    } else if ([indexPath section] == 1) {
        STKInitialProfileStatisticsCell *c = [STKInitialProfileStatisticsCell cellForTableView:tableView target:self];
        [[c circleView] setCircleTitles:@[@"Followers", @"Following", @"Posts"]];
        [[c circleView] setCircleValues:@[@"0", @"0", @"0"]];

        return c;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

@end
