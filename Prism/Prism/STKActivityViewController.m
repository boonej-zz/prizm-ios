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
#import "STKLuminatingBar.h"
#import "STKFetchDescription.h"

typedef enum {
    STKActivityViewControllerTypeActivity,
    STKActivityViewControllerTypeRequest
} STKActivityViewControllerType;

@interface STKActivityViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activityTypeControl;
@property (weak, nonatomic) IBOutlet STKLuminatingBar *luminatingBar;

@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) NSMutableArray *activities;

@property (nonatomic) BOOL activityFetchInProgress;
@property (nonatomic) BOOL requestFetchInProgress;
@property (nonatomic, strong) UIView *underlayView;


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
    CGRect frame = [self.view frame];
    frame.size.height = 64.f;
    self.underlayView = [[UIView alloc] initWithFrame:frame];
    [self.underlayView setBackgroundColor:[UIColor blackColor]];
    [self.underlayView setAlpha:0.0];
    [self.view addSubview:self.underlayView];
    [[self tableView] setRowHeight:56];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:v];

    [[self tableView] setContentInset:UIEdgeInsetsMake(64 + 50, 0, 0, 0)];
    [self addBlurViewWithHeight:114.f];
    [self.view bringSubviewToFront:self.activityTypeControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[[self blurView] displayLink] setPaused:NO];
    [self fetchNewItems];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[[self blurView] displayLink] setPaused:YES];

    [[STKUserStore store] markActivitiesAsRead];
}

- (void)setCurrentType:(STKActivityViewControllerType)currentType
{
    _currentType = currentType;
    [self fetchNewItems];
}

- (void)fetchOlderItems
{
    STKFetchDescription *fd = [[STKFetchDescription alloc] init];
    [fd setDirection:STKQueryObjectPageOlder];
    
    if([self currentType] == STKActivityViewControllerTypeActivity) {
        if ([self activityFetchInProgress]) {
            return;
        }
        [self setActivityFetchInProgress:YES];


        [fd setReferenceObject:[[self activities] lastObject]];
        [[STKUserStore store] fetchActivityForUser:[[STKUserStore store] currentUser]
                                 fetchDescription:fd
                                        completion:^(NSArray *activities, NSError *err) {
                                            [self setActivityFetchInProgress:NO];
                                            if(!err) {
                                                NSMutableSet *activitySet = [NSMutableSet setWithArray:[self activities]];
                                                [activitySet addObjectsFromArray:activities];
                                                [self setActivities:[[activitySet allObjects] mutableCopy]];
                                                
                                                [[self activities] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
                                            }
                                            [[self tableView] reloadData];
                                        }];
        
    } else if([self currentType] == STKActivityViewControllerTypeRequest) {
        if ([self requestFetchInProgress]) {
            return;
        }
        [self setRequestFetchInProgress:YES];
        
        [fd setReferenceObject:[[self requests] lastObject]];
        [[STKUserStore store] fetchRequestsForCurrentUserWithFetchDescription:fd completion:^(NSArray *requests, NSError *err) {
            [self setRequestFetchInProgress:NO];
            if(!err) {
                NSMutableSet *requestSet = [NSMutableSet setWithArray:[self requests]];
                [requestSet addObjectsFromArray:requests];
                [self setRequests:[[requestSet allObjects] mutableCopy]];
                [[self requests] filterUsingPredicate:[NSPredicate predicateWithFormat:@"status != %@", STKRequestStatusCancelled]];
                [[self requests] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:NO]]];
            }
            [[self tableView] reloadData];
        }];
    }
    [[self tableView] reloadData];
}


- (void)fetchNewItems
{
    STKFetchDescription *fd = [[STKFetchDescription alloc] init];
    [fd setDirection:STKQueryObjectPageNewer];
    
    if([self currentType] == STKActivityViewControllerTypeActivity) {
        if ([self activityFetchInProgress]) {
            return;
        }
        [self setActivityFetchInProgress:YES];
        [[self luminatingBar] setLuminating:YES];

        [fd setReferenceObject:[[self activities] firstObject]];
        [[STKUserStore store] fetchActivityForUser:[[STKUserStore store] currentUser]
                                  fetchDescription:fd
                                        completion:^(NSArray *activities, NSError *err) {
                                            [self setActivityFetchInProgress:NO];
                                            [[self luminatingBar] setLuminating:NO];
                                            if(!err) {
                                                NSMutableSet *activitySet = [NSMutableSet setWithArray:[self activities]];
                                                [activitySet addObjectsFromArray:activities];
                                                [self setActivities:[[activitySet allObjects] mutableCopy]];
                                                
                                                [[self activities] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
                                            }
                                            [[self tableView] reloadData];
                                        }];
        
    } else if([self currentType] == STKActivityViewControllerTypeRequest) {
        if ([self requestFetchInProgress]) {
            return;
        }
        [self setRequestFetchInProgress:YES];
        [[self luminatingBar] setLuminating:YES];
        
        [fd setReferenceObject:[[self requests] firstObject]];
        [[STKUserStore store] fetchRequestsForCurrentUserWithFetchDescription:fd completion:^(NSArray *requests, NSError *err) {
            [[self luminatingBar] setLuminating:NO];
            [self setRequestFetchInProgress:NO];
            if(!err) {
                NSMutableSet *requestSet = [NSMutableSet setWithArray:[self requests]];
                [requestSet addObjectsFromArray:requests];
                [self setRequests:[[requestSet allObjects] mutableCopy]];
                [[self requests] filterUsingPredicate:[NSPredicate predicateWithFormat:@"status != %@ && status != %@", STKRequestStatusCancelled, STKRequestStatusRejected]];
                NSSortDescriptor *trustAccepted = [NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO];
                NSSortDescriptor *dateCreated =[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:NO];
                [[self requests] sortUsingDescriptors:@[trustAccepted, dateCreated]];
            }
            [[self tableView] reloadData];
        }];
    }
    [[self tableView] reloadData];
}

- (void)acceptRequest:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[STKUserStore store] acceptTrustRequest:[[self requests] objectAtIndex:[ip row]] completion:^(STKTrust *requestItem, NSError *err) {
        if (err) {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
        [[self tableView] reloadData];
    }];
    [[self tableView] reloadData];
}

- (void)rejectRequest:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[STKUserStore store] rejectTrustRequest:[[self requests] objectAtIndex:[ip row]] completion:^(STKTrust *requestItem, NSError *err) {
        if (err) {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
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
        } else {
            [[cell imageReferenceView] setUrlString:nil];
        }
        
        [[cell timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[i dateCreated]]];

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
    [[self underlayView] setAlpha:0.5];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self underlayView] setAlpha:0.0];
}

- (IBAction)typeChanged:(id)sender
{
    [self setCurrentType:(int)[sender selectedSegmentIndex]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < 0) {
        float t = fabs(offset) / 60.0;
        if(t > 1)
            t = 1;
        [[self luminatingBar] setProgress:t];
    } else {
        [[self luminatingBar] setProgress:0];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(velocity.y > 0 && [scrollView contentSize].height - [scrollView frame].size.height - 20 < targetContentOffset->y) {
        [self fetchOlderItems];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < -60) {
        [self fetchNewItems];
    }
}


@end
