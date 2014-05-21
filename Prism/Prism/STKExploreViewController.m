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
#import "STKProfileViewController.h"
#import "UIERealTimeBlurView.h"
#import "STKTextImageCell.h"
#import "STKPostController.h"
#import "STKNavigationButton.h"
#import "STKSearchResultsViewController.h"


typedef enum {
    STKExploreTypeLatest = 0,
    STKExploreTypePopular = 1,
    STKExploreTypeFeatured = 2
} STKExploreType;


@interface STKExploreViewController ()
    <UITableViewDataSource, UITableViewDelegate, STKPostControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UINavigationController *searchNavController;

@property (nonatomic, strong) STKPostController *recentPostsController;
@property (nonatomic, strong) STKPostController *popularPostsController;
@property (nonatomic, strong) STKPostController *featuredPostsController;
@property (nonatomic, assign) STKPostController *activePostController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *exploreTypeControl;
@property (nonatomic, strong) IBOutlet UIERealTimeBlurView *blurView;


@property (nonatomic, strong) STKNavigationButton *searchButton;
@property (nonatomic, strong) UIBarButtonItem *searchButtonItem;

- (IBAction)exploreTypeChanged:(id)sender;

@end

@implementation STKExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Explore"];
        [[self tabBarItem] setTitle:@"Explore"]
        ;
        STKNavigationButton *view = [[STKNavigationButton alloc] init];
        [view setImage:[UIImage imageNamed:@"btn_search"]];
        [view setHighlightedImage:[UIImage imageNamed:@"btn_search_selected"]];
        [view setSelectedImage:[UIImage imageNamed:@"btn_search_selected"]];
        [view setOffset:8];
        [view addTarget:self action:@selector(initiateSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self setSearchButton:view];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
        [self setSearchButtonItem:bbi];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_explore"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_explore_selected"]];
        
        _recentPostsController = [[STKPostController alloc] initWithViewController:self];
        [[self recentPostsController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fs completion:completion];
        }];
        
        _featuredPostsController = [[STKPostController alloc] initWithViewController:self];
        [[self featuredPostsController] setFilterMap:@{@"creatorType" : STKUserTypeInstitution}];
        [[self featuredPostsController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fs completion:completion];
        }];
        
        _popularPostsController = [[STKPostController alloc] initWithViewController:self];
//        [[self popularPostsController] setFilterMap:@{@"sort_by" : @"likes_count", @"sort" : [NSString stringWithFormat:@"%d", STKQueryObjectSortAscending]}];
        [[self popularPostsController] setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"likeCount" ascending:NO]]];
        [[self popularPostsController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fs completion:completion];
        }];

        
    }
    return self;
}

- (void)initiateSearch:(id)sender
{
    [self setSearchBarActive:![self isSearchBarActive]];
}

- (void)setSearchBarActive:(BOOL)active
{
    if(active) {
        STKSearchResultsViewController *searchController = [[STKSearchResultsViewController alloc] init];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:searchController];
        
        [self addChildViewController:nvc];
        [[self view] addSubview:[nvc view]];
        [nvc didMoveToParentViewController:self];
        
        [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v]|" options:0 metrics:nil views:@{@"v" : [nvc view]}]];
        [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v" : [nvc view]}]];
        [nvc setNavigationBarHidden:YES];
        
        [self setSearchNavController:nvc];
        [[[self blurView] displayLink] setPaused:YES];
        [[self blurView] setHidden:YES];
        
        [[self tableView] setHidden:YES];
        [[self exploreTypeControl] setHidden:YES];
        [[self searchButton] setSelected:YES];
        [[self navigationItem] setTitle:@"Search"];
    } else {
        [[self tableView] setHidden:NO];
        [[self exploreTypeControl] setHidden:NO];
        [[self searchButton] setSelected:NO];

        [[[self blurView] displayLink] setPaused:NO];
        [[self blurView] setHidden:NO];

        
        [[self searchNavController] willMoveToParentViewController:nil];
        [[self searchNavController] removeFromParentViewController];
        [[[self searchNavController] view] removeFromSuperview];
        [self setSearchNavController:nil];
        
        [[self navigationItem] setTitle:@"Explore"];
    }
}




- (BOOL)isSearchBarActive
{
    return [self searchNavController] != nil;
}

- (void)menuWillAppear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.5];
    [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.0];
    [[self navigationItem] setRightBarButtonItem:[self searchButtonItem]];
}

- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx
{
    int row = idx / 3;
    int offset = idx % 3;
    
    STKTriImageCell *c = (STKTriImageCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
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
   /*
    NSArray *posts = [self posts];
    UITableView *tv = [self tableView];
    if([self isSearchBarActive] && [self searchType] == STKSearchTypeHashTag) {
        posts = [self postsFound];
        tv = [self searchResultsTableView];
    }
    if(idx < [posts count]) {
        STKPost *p = [posts objectAtIndex:idx];
        [[self menuController] transitionToPost:p
                                       fromRect:[self rectForPostAtIndex:idx inTableView:tv]
                               inViewController:self
                                       animated:YES];
    }*/
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)swipe:(UISwipeGestureRecognizer *)gr
{
    if([gr state] == UIGestureRecognizerStateEnded) {
        if([gr direction] == UISwipeGestureRecognizerDirectionLeft) {
            if([self exploreType] == STKExploreTypePopular) {
                [[self exploreTypeControl] setSelectedSegmentIndex:2];
                [self exploreTypeChanged:[self exploreTypeControl]];
            } else if ([self exploreType] == STKExploreTypeFeatured) {
               // [[self exploreTypeControl] setSelectedSegmentIndex:0];
               // [self exploreTypeChanged:[self exploreTypeControl]];
            } else {
                [[self exploreTypeControl] setSelectedSegmentIndex:1];
                [self exploreTypeChanged:[self exploreTypeControl]];
            }
        } else {
            if([self exploreType] == STKExploreTypeLatest) {
               // [[self exploreTypeControl] setSelectedSegmentIndex:2];
               // [self exploreTypeChanged:[self exploreTypeControl]];
            } else if([self exploreType] == STKExploreTypeFeatured) {
                [[self exploreTypeControl] setSelectedSegmentIndex:1];
                [self exploreTypeChanged:[self exploreTypeControl]];
            } else {
                [[self exploreTypeControl] setSelectedSegmentIndex:0];
                [self exploreTypeChanged:[self exploreTypeControl]];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [leftSwipe setDelegate:self];
    [[self view] addGestureRecognizer:leftSwipe];

    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [rightSwipe setDelegate:self];
    [[self view] addGestureRecognizer:rightSwipe];

    
    [[self tableView] setRowHeight:106];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}

- (STKExploreType)exploreType
{
    return (STKExploreType)[[self exploreTypeControl] selectedSegmentIndex];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if([self exploreType] == STKExploreTypeLatest)
        [self setActivePostController:[self recentPostsController]];
    else if([self exploreType] == STKExploreTypePopular)
        [self setActivePostController:[self popularPostsController]];
    else if ([self exploreType] == STKExploreTypeFeatured)
        [self setActivePostController:[self featuredPostsController]];

    
    [[self searchButton] setSelected:[self isSearchBarActive]];
    
    [[[self blurView] displayLink] setPaused:NO];

    [[self tableView] setContentInset:UIEdgeInsetsMake([[self exploreTypeControl] frame].origin.y + [[self exploreTypeControl] frame].size.height, 0, 0, 0)];

    STKPostController *pc = [self activePostController];
    [pc fetchNewerPostsWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int postCount = [[[self activePostController] posts] count];
    if(postCount % 3 > 0)
        return postCount / 3 + 1;
    return postCount / 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self activePostController]];
    [c populateWithPosts:[[self activePostController] posts] indexOffset:[indexPath row] * 3];
    return c;
}


- (IBAction)exploreTypeChanged:(UISegmentedControl *)sender
{
    if([self exploreType] == STKExploreTypeLatest)
        [self setActivePostController:[self recentPostsController]];
    else if([self exploreType] == STKExploreTypePopular)
        [self setActivePostController:[self popularPostsController]];
    else if([self exploreType] == STKExploreTypeFeatured)
        [self setActivePostController:[self featuredPostsController]];

    [[self tableView] reloadData];
    STKPostController *pc = [self activePostController];
    [pc reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
}



@end
