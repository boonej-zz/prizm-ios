//
//  STKExploreViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKExploreViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKExploreCell.h"
#import "STKPanelViewController.h"
#import "STKRenderServer.h"
#import "STKTriImageCell.h"
#import "STKPost.h"
#import "STKResolvingImageView.h"
#import "STKContentStore.h"
#import "STKPostViewController.h"
#import "STKUserStore.h"
#import "STKSearchProfileCell.h"
#import "STKProfileViewController.h"
#import "UIERealTimeBlurView.h"


@interface STKExploreViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *posts;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *profilesFound;

@end

@implementation STKExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Explore"];
        [[self navigationItem] setRightBarButtonItem:[self searchBarButtonItem]];
        
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_explore"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_explore_selected"]];
        _posts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initiateSearch:(id)sender
{
    float top = [[self tableView] contentInset].top;
    if(-[[self tableView] contentOffset].y == top) {
        [[self tableView] setContentOffset:CGPointMake(0, [[self searchBar] bounds].size.height - top) animated:YES];
    } else {
        [[self tableView] setContentOffset:CGPointMake(0, -top) animated:YES];
    }
    
}

- (void)menuWillAppear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.5];
    [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.0];
    [[self navigationItem] setRightBarButtonItem:[self searchBarButtonItem]];
}



- (void)showPostAtIndex:(int)idx
{
    if(idx < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:idx];
        STKPostViewController *vc = [[STKPostViewController alloc] init];
        [vc setPost:p];

        [[self navigationController] pushViewController:vc animated:YES];
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
    [[self tableView] setTableHeaderView:[self searchBar]];
    
    float top = [[self tableView] contentInset].top;
    [[self tableView] setContentOffset:CGPointMake(0, [[self searchBar] bounds].size.height - top) animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [[[self blurView] displayLink] setPaused:NO];


    [[STKContentStore store] fetchExplorePostsInDirection:STKContentStoreFetchDirectionNewer
                                            referencePost:[[self posts] firstObject]
                                               completion:^(NSArray *posts, NSError *err) {
                                                   if(!err) {
                                                       [[self posts] addObjectsFromArray:posts];
                                                       [[self posts] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
                                                       [[self tableView] reloadData];
                                                       
                                                   } else {
                                                       // Do nothing?
                                                   }
                                               }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self tableView]) {
        [cell setBackgroundColor:[UIColor clearColor]];
        return;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == [self tableView]) {
        if([[self posts] count] % 3 > 0)
            return [[self posts] count] / 3 + 1;
        return [[self posts] count] / 3;
    }
    
    return [[self profilesFound] count];
}

- (void)populateTriImageCell:(STKTriImageCell *)c forRow:(int)row
{
    int arrayIndex = row * 3;
    
    if(arrayIndex + 0 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 0];
        [[c leftImageView] setUrlString:[p imageURLString]];
    } else {
        [[c leftImageView] setUrlString:nil];
    }
    if(arrayIndex + 1 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 1];
        [[c centerImageView] setUrlString:[p imageURLString]];
    } else {
        [[c centerImageView] setUrlString:nil];
    }
    
    if(arrayIndex + 2 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 2];
        [[c rightImageView] setUrlString:[p imageURLString]];
    } else {
        [[c rightImageView] setUrlString:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self tableView]) {
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:self];
        [self populateTriImageCell:c forRow:(int)[indexPath row]];
        
        return c;
    }
    
    STKSearchProfileCell *c = [STKSearchProfileCell cellForTableView:tableView target:self];
    STKUser *u = [[self profilesFound] objectAtIndex:[indexPath row]];
    [[c nameLabel] setText:[u name]];
    [[c avatarView] setUrlString:[u profilePhotoPath]];

    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [[self searchDisplayController] searchResultsTableView]) {
        STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
        
        [pvc setProfile:[[self profilesFound] objectAtIndex:[indexPath row]]];
        [[self navigationController] pushViewController:pvc animated:YES];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if([searchString length] == 0)
        return YES;
    
    [[STKUserStore store] searchUsersWithName:searchString completion:^(NSArray *profiles, NSError *err) {
        if(!err) {
            _profilesFound = profiles;
            [[controller searchResultsTableView] reloadData];
        }
    }];
    return NO;
}

@end
