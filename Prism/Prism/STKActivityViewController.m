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
#import "STKPost.h"
#import "STKPostViewController.h"
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
@property (nonatomic, strong) NSMutableDictionary *itemsViewed;

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
        [[self tabBarItem] setTitle:@"Activity"];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
        _activities = [[NSMutableArray alloc] init];
        _requests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setRowHeight:56];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:v];

    [[self tableView] setContentInset:UIEdgeInsetsMake(64 + 50, 0, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    [self refresh];
}

- (void)premarkItemAsViewed:(id)item
{
    if(![self itemsViewed]) {
        _itemsViewed = [[NSMutableDictionary alloc] init];
    }
    [[self itemsViewed] setObject:@(YES) forKey:[item uniqueID]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];

    [[STKUserStore store] markItemsAsViewed:[[self itemsViewed] allKeys]];
    [self setItemsViewed:nil];
}

- (void)setCurrentType:(STKActivityViewControllerType)currentType
{
    _currentType = currentType;
    [self refresh];
}


- (void)refresh
{
    if([self currentType] == STKActivityViewControllerTypeActivity) {
        
        [[STKUserStore store] fetchActivityForUser:[[STKUserStore store] currentUser]
                                 referenceActivity:[[self activities] firstObject]
                                        completion:^(NSArray *activities, NSError *err) {
                                            [[self activities] addObjectsFromArray:activities];
                                            
                                            [[self activities] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
                                            [[self tableView] reloadData];
                                        }];
        
    } else if([self currentType] == STKActivityViewControllerTypeRequest) {
        [[STKUserStore store] fetchRequestsForCurrentUserWithReferenceRequest:[[self requests] firstObject] completion:^(NSArray *requests, NSError *err) {
            if(!err) {
                requests = [requests filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"not (uniqueID in %@)", [[self requests] valueForKey:@"uniqueID"]]];
                
                [[self requests] addObjectsFromArray:requests];
                [[self requests] filterUsingPredicate:[NSPredicate predicateWithFormat:@"status != %@", STKRequestStatusCancelled]];
                [[self requests] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:NO]]];
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
    STKUser *u = [[[self requests] objectAtIndex:[ip row]] creator];
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:u];
    [[self navigationController] pushViewController:vc animated:YES];

}
- (void)profileImageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKActivityItem *i = [[self activities] objectAtIndex:[ip row]];
    if([i creator]) {
        STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
        [pvc setProfile:[i creator]];
        [[self navigationController] pushViewController:pvc animated:YES];
    }
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
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self currentType] == STKActivityViewControllerTypeRequest) {
    } else if([self currentType] == STKActivityViewControllerTypeActivity) {
        STKActivityItem *i = [[self activities] objectAtIndex:[indexPath row]];
        
        if([i post]) {
            STKActivityCell *c = (STKActivityCell *)[tableView cellForRowAtIndexPath:indexPath];
            [[self menuController] transitionToPost:[i post]
                                           fromRect:[[self view] convertRect:[[c imageReferenceView] frame] fromView:c]
                                         usingImage:[[c imageReferenceView] image]
                                   inViewController:self
                                           animated:YES];
            return;
        }
        
        
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
        
        if([i post]) {
            [[cell imageReferenceView] setUrlString:[[i post] imageURLString]];
        }
        
        [[cell timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[i dateCreated]]];
        [self premarkItemAsViewed:i];
        return cell;
    } else if ([self currentType] == STKActivityViewControllerTypeRequest) {
        STKRequestCell *cell = [STKRequestCell cellForTableView:tableView target:self];

        STKTrust *i = [[self requests] objectAtIndex:[indexPath row]];
        [cell populateWithTrust:i];
        [self premarkItemAsViewed:i];

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
