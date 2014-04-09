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
#import "STKUserStore.h"
#import "STKRequestCell.h"
#import "STKTrust.h"
#import "STKRelativeDateConverter.h"
#import "UIERealTimeBlurView.h"
#import "STKUser.h"
#import "STKProfileViewController.h"

typedef enum {
    STKActivityViewControllerTypeActivity,
    STKActivityViewControllerTypeRequest
} STKActivityViewControllerType;

@interface STKActivityViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activityTypeControl;

@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) NSMutableArray *activities;

@property (nonatomic) STKActivityViewControllerType currentType;
- (IBAction)typeChanged:(id)sender;

@end

@implementation STKActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Activity"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_notification"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_notification_selected"]];

        _activities = [[NSMutableArray alloc] init];
        _requests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
    [[self tableView] setSeparatorColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:v];

    // 'On state'
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [[UIColor colorWithRed:157.0/255.0 green:176.0/255.0 blue:200.0/255.0 alpha:0.5] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [[self activityTypeControl] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext()
                                         forState:UIControlStateSelected
                                       barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
    [[self activityTypeControl] setTitleTextAttributes:@{NSFontAttributeName : STKFont(16),
                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:70.0/255.0 green:34.0/255.0 blue:151.0/255.0 alpha:1]}
                                             forState:UIControlStateSelected];
    
    
    // 'Off' state
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [[UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:157.0/255.0 alpha:0.4] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [[self activityTypeControl] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext()
                                         forState:UIControlStateNormal
                                       barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
    [[self activityTypeControl] setTitleTextAttributes:@{NSFontAttributeName : STKFont(16),
                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}
                                             forState:UIControlStateNormal];
    
    // Divider
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [[UIColor colorWithRed:74.0/255.0 green:114.0/255.0 blue:153.0/255.0 alpha:0.8] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [[self activityTypeControl] setDividerImage:UIGraphicsGetImageFromCurrentImageContext()
                           forLeftSegmentState:UIControlStateNormal
                             rightSegmentState:UIControlStateNormal
                                    barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];

}

- (void)setCurrentType:(STKActivityViewControllerType)currentType
{
    _currentType = currentType;
    [self refresh];
}

- (NSArray *)filterActivities:(NSArray *)activities
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    
    // Find all 'follows' that aren't you.
    [a addObjectsFromArray:[activities filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@ and creator != %@", STKActivityItemTypeFollow, [[STKUserStore store] currentUser]]]];
    [a addObjectsFromArray:[activities filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@ and creator != %@", STKActivityItemTypeLike, [[STKUserStore store] currentUser]]]];
    
    
    return a;
}

- (void)refresh
{
    if([self currentType] == STKActivityViewControllerTypeActivity) {
        
        [[STKUserStore store] fetchActivityForUser:[[STKUserStore store] currentUser] completion:^(NSArray *activities, NSError *err) {
            [[self activities] addObjectsFromArray:[self filterActivities:activities]];
            [[self tableView] reloadData];
        }];
        
    } else if([self currentType] == STKActivityViewControllerTypeRequest) {
        [[STKUserStore store] fetchRequestsForCurrentUser:^(NSArray *requests, NSError *err) {
            if(!err) {
                [[self requests] addObjectsFromArray:requests];
                [[self requests] filterUsingPredicate:[NSPredicate predicateWithFormat:@"status == %@", STKRequestStatusPending]];
            }
            [[self tableView] reloadData];
        }];
    }
}

- (void)acceptRequest:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[STKUserStore store] acceptTrustRequest:[[self requests] objectAtIndex:[ip row]] completion:^(STKTrust *requestItem, NSError *err) {
        [[self tableView] reloadData];
    }];
    [[self tableView] reloadData];
}

- (void)rejectRequest:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[STKUserStore store] rejectTrustRequest:[[self requests] objectAtIndex:[ip row]] completion:^(STKTrust *requestItem, NSError *err) {
        [[self tableView] reloadData];
    }];
    [[self tableView] reloadData];
}

- (void)profileTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self currentType] == STKActivityViewControllerTypeRequest)
        return [[self requests] count];
    
    if([self currentType] == STKActivityViewControllerTypeActivity)
        return [[self activities] count];
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self currentType] == STKActivityViewControllerTypeRequest) {
        STKUser *u = [[[self requests] objectAtIndex:[indexPath row]] otherUser];
        STKProfileViewController *vc = [[STKProfileViewController alloc] init];
        [vc setProfile:u];
        [[self navigationController] pushViewController:vc animated:YES];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self currentType] == STKActivityViewControllerTypeActivity) {
        STKActivityCell *cell = [STKActivityCell cellForTableView:tableView target:self];
        STKActivityItem *i = [[self activities] objectAtIndex:[indexPath row]];
        STKUser *u = [i creator];
        
        [[cell profileImageView] setUrlString:[u profilePhotoPath]];
        
        [[cell recentIndicatorImageView] setHidden:[i hasBeenViewed]];
        [[cell nameLabel] setText:[u name]];
        [[cell activityTypeLabel] setText:[i text]];
        //[[cell imageReferenceView] setUrlString:[i referenceImageURLString]];
        return cell;
    } else if ([self currentType] == STKActivityViewControllerTypeRequest) {
        STKRequestCell *cell = [STKRequestCell cellForTableView:tableView target:self];

        STKTrust *i = [[self requests] objectAtIndex:[indexPath row]];
        [cell populateWithTrust:i];
        
        return cell;
    }
    
    return nil;
}

- (void)menuWillAppear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.5];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.0];
}


- (IBAction)typeChanged:(id)sender
{
    [self setCurrentType:[sender selectedSegmentIndex]];
    [[self tableView] reloadData];
}

@end
