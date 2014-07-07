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
#import "STKLuminatingBar.h"
#import "Mixpanel.h"
#import "STKExploreFilterViewController.h"

@interface STKExploreViewController ()
    <UITableViewDataSource, UITableViewDelegate, STKPostControllerDelegate, UIGestureRecognizerDelegate, STKExploreFilterDelegate>

@property (nonatomic, strong) UINavigationController *searchNavController;
@property (nonatomic, strong) UINavigationController *filterNavController;

@property (nonatomic, strong) STKPostController *recentPostsController;
@property (nonatomic, strong) STKPostController *popularPostsController;
@property (nonatomic, strong) STKPostController *featuredPostsController;
@property (nonatomic, assign) STKPostController *activePostController;

@property (weak, nonatomic) IBOutlet STKLuminatingBar *luminatingBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *exploreTypeControl;
@property (nonatomic, strong) IBOutlet UIERealTimeBlurView *blurView;

@property (nonatomic, strong) STKNavigationButton *searchButton;
@property (nonatomic, strong) STKNavigationButton *filterButton;
@property (nonatomic, strong) STKNavigationButton *cancelButton;

@property (nonatomic, strong) UIBarButtonItem *searchButtonItem;
@property (nonatomic, strong) UIBarButtonItem *filterButtonItem;
@property (nonatomic, strong) NSDictionary *activeFilter;
@property (nonatomic, strong) NSDictionary *defaultFeaturedFilter;
@property (nonatomic, assign) BOOL isShowingFilterView;

- (IBAction)exploreTypeChanged:(id)sender;

@end

@implementation STKExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Explore"];
        [[self tabBarItem] setTitle:@"Explore"];
        
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_explore"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_explore_selected"]];
        
        //set default Featured filters dict
        [self setDefaultFeaturedFilter:@{@"key" : @"creatorType", @"filter" : STKUserTypeInstitution}];
        
        _recentPostsController = [[STKPostController alloc] initWithViewController:self];
        [[self recentPostsController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fs completion:completion];
        }];
        
        _featuredPostsController = [[STKPostController alloc] initWithViewController:self];
//        [[self featuredPostsController] setFilterMap:@{@"creatorType" : STKUserTypeInstitution}];
        [[self featuredPostsController] setFilterMap:[self filterMap]];
        [[self featuredPostsController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fs completion:completion];
        }];
        
        _popularPostsController = [[STKPostController alloc] initWithViewController:self];
//        [[self popularPostsController] setFilterMap:@{@"sort_by" : @"likes_count", @"sort" : [NSString stringWithFormat:@"%d", STKQueryObjectSortAscending]}];
        [[self popularPostsController] setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"likeCount" ascending:NO]]];
        [[self popularPostsController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fs completion:completion];
        }];
        
        [self configureInterface];
    }
    return self;
}

- (void)initiateSearch:(id)sender
{
    [self setSearchBarActive:![self isSearchBarActive]];
}

- (void)initiateFilter:(id)sender
{
    [self setFilterScreenActive:![self isFilterScreenActive]];
}

- (void)setFilterScreenActive:(BOOL)active
{
    if(active) {
        STKExploreFilterViewController *filtervc = [[STKExploreFilterViewController alloc] init];
        [filtervc setDelegate:self];
        [filtervc setFilters:[self activeFilter]];

        CGRect r = CGRectMake(0, 64, 320, [filtervc menuHeight]);
        UIImage *bgImage = [[STKRenderServer renderServer] instantBlurredImageForView:[self view]
                                                                            inSubrect:r];
        [filtervc setBackgroundImage:bgImage];

        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:filtervc];
        [self setFilterNavController:nvc];
        [self setOverlayViewController:nvc];
    } else {
        [self setOverlayViewController:nil];
        [self setFilterNavController:nil];
    }
    [self configureInterface];
}
- (BOOL)isFilterScreenActive
{
    return [self filterNavController] != nil;
}

- (void)setSearchBarActive:(BOOL)active
{
    if(active) {
        STKSearchResultsViewController *searchController = [[STKSearchResultsViewController alloc] init];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:searchController];
        
        [self setOverlayViewController:nvc];
        [self setSearchNavController:nvc];
    } else {
        [self setOverlayViewController:nil];
        [self setSearchNavController:nil];
    }
    [self configureInterface];
}

- (BOOL)isSearchBarActive
{
    return [self searchNavController] != nil;
}

- (void)setOverlayViewController:(UINavigationController *)vc
{
    for(UIViewController *cvc in [self childViewControllers]) {
        [cvc willMoveToParentViewController:nil];
        [[cvc view] removeFromSuperview];
        [cvc removeFromParentViewController];
    }
    
    if(vc) {
        [vc setNavigationBarHidden:YES];
        [self addChildViewController:vc];
        [[self view] addSubview:[vc view]];
        
        [[vc view] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v]|" options:0 metrics:nil views:@{@"v" : [vc view]}]];
        [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v" : [vc view]}]];
        
        [vc didMoveToParentViewController:self];
    }
}


- (void)menuWillAppear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.5];
    [[self navigationItem] setRightBarButtonItems:nil];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.0];
    [self configureInterface];
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
    
    [[self luminatingBar] setLuminationOpacity:1];
    
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

    
    [[[self blurView] displayLink] setPaused:NO];

    [[self tableView] setContentInset:UIEdgeInsetsMake([[self exploreTypeControl] frame].origin.y + [[self exploreTypeControl] frame].size.height, 0, 0, 0)];

    [self reloadPosts];
    [self configureInterface];
    [[Mixpanel sharedInstance] track:@"Explore Viewed" properties:@{@"Explore Type" : [self exploreTypeString]}];
}

- (void)dismissOverlay:(id)sender
{
    if([self isSearchBarActive]) {
        [self setSearchBarActive:NO];
    } else if([self isFilterScreenActive]) {
        [self setFilterScreenActive:NO];
        [self reloadPosts];
    }
}

- (void)configureInterface
{
    [[self exploreTypeControl] setSelectedSegmentIndex:[self exploreType]];
    
    if(![self cancelButton]) {
        STKNavigationButton *cancelButton = [[STKNavigationButton alloc] init];
        [cancelButton setImage:[UIImage imageNamed:@"btn_cancel"]];
        [cancelButton setOffset:8];
        [cancelButton addTarget:self action:@selector(dismissOverlay:) forControlEvents:UIControlEventTouchUpInside];
        [self setCancelButton:cancelButton];
    }
    if(![self searchButton]) {
        STKNavigationButton *view = [[STKNavigationButton alloc] init];
        [view setImage:[UIImage imageNamed:@"btn_search"]];
        [view setOffset:8];
        [view addTarget:self action:@selector(initiateSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self setSearchButton:view];
    }
    if(![self filterButton]) {
        STKNavigationButton *filterView = [[STKNavigationButton alloc] init];
        [filterView setImage:[UIImage imageNamed:@"filter_active"]];
        [filterView setHighlightedImage:[UIImage imageNamed:@"filter_activeon"]];
        [filterView setSelectedImage:[UIImage imageNamed:@"filter_activeon"]];
        [filterView setOffset:8];
        [filterView addTarget:self action:@selector(initiateFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self setFilterButton:filterView];
    }
    
    [[self navigationItem] setTitle:@"Explore"];

    
    if([self isFilterScreenActive]) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:[self cancelButton]];
        [[self navigationItem] setRightBarButtonItems:@[bbi]];
    } else if([self isSearchBarActive]) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:[self cancelButton]];
        [[self navigationItem] setRightBarButtonItems:@[bbi]];
        [[self navigationItem] setTitle:@"Search"];
    } else {
        UIBarButtonItem *bbiSearch = [[UIBarButtonItem alloc] initWithCustomView:[self searchButton]];
        UIBarButtonItem *bbiFilter = [[UIBarButtonItem alloc] initWithCustomView:[self filterButton]];
        [[self navigationItem] setRightBarButtonItems:@[bbiSearch, bbiFilter]];
        if([self isFilterActive]) {
            [[self filterButton] setSelected:YES];
        }
    }
}

- (NSString *)exploreTypeString
{
    NSDictionary *map = @{
                          @(STKExploreTypeFeatured) : @"featured",
                          @(STKExploreTypeLatest) : @"latest",
                          @(STKExploreTypePopular) : @"popular"
                          };
    return map[@([self exploreType])];
}
     
- (void)reloadPosts
{
    STKPostController *pc = [self activePostController];
    NSDictionary *filterMap = [self filterMap];
    [pc setFilterMap:filterMap];
    
    [[self luminatingBar] setLuminating:YES];
    [pc reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self luminatingBar] setLuminating:NO];
        [[self tableView] reloadData];
    }];
}

- (NSDictionary *)filterMap
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    if([self exploreType] == STKExploreTypeFeatured) {
        [d setObject:STKUserTypeInstitution forKey:@"creatorType"];
    }
    
    [d addEntriesFromDictionary:[self activeFilter]];
    
    return d;
}

- (BOOL)isFilterActive
{
    return [[self activeFilter] count] > 0;
}

- (void)exploreFilterViewController:(STKExploreFilterViewController *)vc
                   didUpdateFilters:(NSDictionary *)filter
{
    [self setActiveFilter:filter];
}

- (void)didDismissExploreFilterViewController:(STKExploreFilterViewController *)vc
{
    [self dismissOverlay:nil];
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
    [self setExploreType:[sender selectedSegmentIndex]];
    
    if([self exploreType] == STKExploreTypeLatest)
        [self setActivePostController:[self recentPostsController]];
    else if([self exploreType] == STKExploreTypePopular)
        [self setActivePostController:[self popularPostsController]];
    else if([self exploreType] == STKExploreTypeFeatured)
        [self setActivePostController:[self featuredPostsController]];

    [[self tableView] reloadData];
    [self reloadPosts];
    
    [[Mixpanel sharedInstance] track:@"Explore Viewed" properties:@{@"Explore Type" : [self exploreTypeString]}];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < -60) {
        [self reloadPosts];
    }
}


@end




