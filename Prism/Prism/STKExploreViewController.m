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
#import "STKTextImageCell.h"
#import "STKPostController.h"
#import "STKNavigationButton.h"


typedef enum {
    STKExploreTypeLatest = 0,
    STKExploreTypePopular = 1
} STKExploreType;

typedef enum {
    STKSearchTypeUser,
    STKSearchTypeHashTag
} STKSearchType;

@interface STKExploreViewController ()
    <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STKPostControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *filterPostOptions;

@property (nonatomic, strong) STKPostController *recentPostsController;
@property (nonatomic, strong) STKPostController *popularPostsController;
@property (nonatomic, assign) STKPostController *activePostController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *exploreTypeControl;
@property (nonatomic, strong) IBOutlet UIERealTimeBlurView *blurView;

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *filterOptionView;

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UIButton *usersFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *hashTagFilterButton;
@property (nonatomic) STKSearchType searchType;
@property (nonatomic, strong) NSArray *postsFound;
@property (nonatomic, strong) NSArray *profilesFound;
@property (nonatomic, strong) STKNavigationButton *searchButton;
@property (nonatomic, strong) UIBarButtonItem *searchButtonItem;

- (IBAction)exploreTypeChanged:(id)sender;
- (IBAction)showHashTagResults:(id)sender;
- (IBAction)showUserResults:(id)sender;
- (IBAction)toggleFilterView:(id)sender;

@end

@implementation STKExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Explore"];
        
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
        
        _popularPostsController = [[STKPostController alloc] initWithViewController:self];
        [_popularPostsController setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"likeCount" ascending:NO],
                                                      [NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];

        
    }
    return self;
}

- (IBAction)dismissSearchContainer:(id)sender
{
    [self setSearchBarActive:NO];
}
- (void)initiateSearch:(id)sender
{
    [self setSearchBarActive:![self isSearchBarActive]];
}

- (void)setSearchBarActive:(BOOL)active
{
    if(active) {
        [[self tableView] setHidden:YES];
        [[self searchContainer] setHidden:NO];
        [[self exploreTypeControl] setHidden:YES];
        [[self searchTextField] becomeFirstResponder];
        [[self searchButton] setSelected:YES];
        [[self navigationItem] setTitle:@"Search"];
        [self reloadSearchResults];
    } else {
        [[self tableView] setHidden:NO];

        [[self searchTextField] setText:nil];
        [[self searchContainer] setHidden:YES];
        [[self exploreTypeControl] setHidden:NO];
        [[self searchButton] setSelected:NO];

        [[self navigationItem] setTitle:@"Explore"];
        
        [[self view] endEditing:YES];
    }
}

- (void)toggleFollow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *u = [[self profilesFound] objectAtIndex:[ip row]];
    if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[STKUserStore store] unfollowUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self searchResultsTableView] cellForRowAtIndexPath:ip] followButton] setSelected:NO];
            }
        }];
    } else {
        [[STKUserStore store] followUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self searchResultsTableView] cellForRowAtIndexPath:ip] followButton] setSelected:YES];
            }
        }];
    }
}

- (void)refreshSearchTypeControl
{
    UIColor *onColor = [UIColor colorWithRed:157.0/255.0 green:176.0/255.0 blue:200.0/255.0 alpha:0.5];
    UIColor *offColor = [UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:157.0/255.0 alpha:0.4];
    UIColor *onTextColor = [UIColor colorWithRed:70.0/255.0 green:34.0/255.0 blue:151.0/255.0 alpha:1];
    if([self searchType] == STKSearchTypeHashTag) {
        [[self usersFilterButton] setBackgroundColor:offColor];
        [[self hashTagFilterButton] setBackgroundColor:onColor];
        [[self hashTagFilterButton] setTitleColor:onTextColor forState:UIControlStateNormal];
        [[self usersFilterButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [[self usersFilterButton] setBackgroundColor:onColor];
        [[self hashTagFilterButton] setBackgroundColor:offColor];
        [[self usersFilterButton] setTitleColor:onTextColor forState:UIControlStateNormal];
        [[self hashTagFilterButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (BOOL)isSearchBarActive
{
    return ![[self searchContainer] isHidden];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == [self searchResultsTableView])
        [[self searchTextField] resignFirstResponder];
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
        if([gr direction] == UISwipeGestureRecognizerDirectionRight) {
            if([self exploreType] == STKExploreTypePopular) {
                [[self exploreTypeControl] setSelectedSegmentIndex:0];
                [self exploreTypeChanged:[self exploreTypeControl]];
            }
        } else {
            if([self exploreType] == STKExploreTypeLatest) {
                [[self exploreTypeControl] setSelectedSegmentIndex:1];
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

//    [[[self usersFilterButton] layer] setCornerRadius:5];
//    [[[self hashTagFilterButton] layer] setCornerRadius:5];
//    [[self usersFilterButton] setClipsToBounds:YES];
//    [[self hashTagFilterButton] setClipsToBounds:YES];
    [self refreshSearchTypeControl];
    
    [[self filterOptionView] registerNib:[UINib nibWithNibName:@"STKTextImageCell" bundle:nil]
                    forCellWithReuseIdentifier:@"STKTextImageCell"];
    [[self filterOptionView] setBackgroundColor:[UIColor clearColor]];
    [[self filterOptionView] setScrollEnabled:NO];

    [[self searchResultsTableView] setBackgroundColor:[UIColor clearColor]];
    [[self searchResultsTableView] setSeparatorColor:STKTextTransparentColor];
    [[self searchResultsTableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self searchResultsTableView] setTableFooterView:v];

    
    [self configureSearchArea];
    [self configureSegmentedControl];
}

- (STKExploreType)exploreType
{
    return [[self exploreTypeControl] selectedSegmentIndex];
}

- (void)refreshPosts
{
    NSDictionary *filter = nil;
    if([self exploreType] == STKExploreTypeLatest) {
        filter = nil;
    } else {
        filter = @{@"sort_field" : @"likes_count"};
    }

    STKPostController *pc = [self activePostController];
    [[STKContentStore store] fetchExplorePostsInDirection:STKQueryObjectPageNewer
                                            referencePost:[[[self activePostController] posts] firstObject]
                                                   filter:filter
                                               completion:^(NSArray *posts, NSError *err) {
                                                   if(!err)
                                                       [pc addPosts:posts];
                                                   
                                                   [[self tableView] reloadData];
                                               }];
}

- (void)configureSearchArea
{
}

- (void)configureSegmentedControl
{
    // 'On state'
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    //[[UIColor colorWithRed:0.86 green:0.87 blue:.92 alpha:0.3] set];
    [[UIColor colorWithRed:157.0/255.0 green:176.0/255.0 blue:200.0/255.0 alpha:0.5] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [[self exploreTypeControl] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext()
                                         forState:UIControlStateSelected
                                       barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
    [[self exploreTypeControl] setTitleTextAttributes:@{NSFontAttributeName : STKFont(16),
                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:70.0/255.0 green:34.0/255.0 blue:151.0/255.0 alpha:1]}
                                             forState:UIControlStateSelected];

    
    // 'Off' state
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [[UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:157.0/255.0 alpha:0.4] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [[self exploreTypeControl] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext()
                                         forState:UIControlStateNormal
                                       barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
    [[self exploreTypeControl] setTitleTextAttributes:@{NSFontAttributeName : STKFont(16),
                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}
                                             forState:UIControlStateNormal];

    // Divider
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    [[UIColor colorWithRed:74.0/255.0 green:114.0/255.0 blue:153.0/255.0 alpha:0.8] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    [[self exploreTypeControl] setDividerImage:UIGraphicsGetImageFromCurrentImageContext()
                           forLeftSegmentState:UIControlStateNormal
                             rightSegmentState:UIControlStateNormal
                                    barMetrics:UIBarMetricsDefault];
    UIGraphicsEndImageContext();
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

    [[self searchButton] setSelected:[self isSearchBarActive]];
    
    [[[self blurView] displayLink] setPaused:NO];

    [[self tableView] setContentInset:UIEdgeInsetsMake([[self exploreTypeControl] frame].origin.y + [[self exploreTypeControl] frame].size.height, 0, 0, 0)];

    [self refreshPosts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[STKSearchProfileCell class]]) {
        [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
    } else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self tableView])
        return [[self tableView] rowHeight];
    
    if([self searchType] == STKSearchTypeHashTag) {
        return [[self tableView] rowHeight];
    }
    
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == [self tableView]) {
        
        int postCount = [[[self activePostController] posts] count];
        if(postCount % 3 > 0)
            return postCount / 3 + 1;
        return postCount / 3;
    }
    
    if([self searchType] == STKSearchTypeHashTag)
        return [[self postsFound] count];
    
    return [[self profilesFound] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self tableView]) {
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self activePostController]];
        [c populateWithPosts:[[self activePostController] posts] indexOffset:[indexPath row] * 3];
        return c;
    }
    
    if([self searchType] == STKSearchTypeHashTag) {
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:self];
        [c populateWithPosts:[self postsFound] indexOffset:[indexPath row] * 3];
        
        return c;
    }
    
    STKSearchProfileCell *c = [STKSearchProfileCell cellForTableView:tableView target:self];
    STKUser *u = [[self profilesFound] objectAtIndex:[indexPath row]];
    [[c nameLabel] setTextColor:STKTextColor];
    [[c nameLabel] setText:[u name]];
    [[c avatarView] setUrlString:[u profilePhotoPath]];

    if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[c followButton] setSelected:YES];
    } else {
        [[c followButton] setSelected:NO];
    }

    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self searchResultsTableView] && [self searchType] == STKSearchTypeUser) {
        STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
        [pvc setProfile:[[self profilesFound] objectAtIndex:[indexPath row]]];
        [[self navigationController] pushViewController:pvc animated:YES];
    }
}


- (IBAction)searchFieldDidChange:(UITextField *)sender
{
    NSString *searchString = [sender text];
    if([searchString length] < 2) {
        [self reloadSearchResults];
        return;
    }
    if([self searchType] == STKSearchTypeHashTag) {
        [[STKContentStore store] searchPostsForHashtag:searchString completion:^(NSArray *posts, NSError *err) {
            [self setPostsFound:posts];
            [self reloadSearchResults];
        }];
    } else {
        [[STKUserStore store] searchUsersWithName:searchString completion:^(NSArray *profiles, NSError *err) {
            if(!err) {
                _profilesFound = profiles;
                [self reloadSearchResults];
            }
        }];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self setProfilesFound:nil];
    [self reloadSearchResults];
    return YES;
}

- (void)reloadSearchResults
{
    if([self searchType] == STKSearchTypeHashTag) {
        
        [[self searchResultsTableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

        if([[self postsFound] count] == 0) {
            [[self searchResultsTableView] setHidden:YES];
        } else {
            [[self searchResultsTableView] setHidden:NO];
        }
    } else {
        [[self searchResultsTableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        if([[self profilesFound] count] == 0) {
            [[self searchResultsTableView] setHidden:YES];
        } else {
            [[self searchResultsTableView] setHidden:NO];
        }
    }
    [[self searchResultsTableView] reloadData];
}

- (IBAction)exploreTypeChanged:(UISegmentedControl *)sender
{
    if([self exploreType] == STKExploreTypeLatest)
        [self setActivePostController:[self recentPostsController]];
    else if([self exploreType] == STKExploreTypePopular)
        [self setActivePostController:[self popularPostsController]];

    [[self tableView] reloadData];
    [self refreshPosts];
}

- (IBAction)showHashTagResults:(id)sender
{
    [self setSearchType:STKSearchTypeHashTag];
    [self refreshSearchTypeControl];
}

- (IBAction)showUserResults:(id)sender
{
    [self setSearchType:STKSearchTypeUser];
    [self refreshSearchTypeControl];
}

- (IBAction)toggleFilterView:(id)sender
{
//    [[self filterOptionView] setHidden:![[self filterOptionView] isHidden]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self filterPostOptions] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[self filterPostOptions] objectAtIndex:[indexPath row]];
    STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                           forIndexPath:indexPath];
    [[cell label] setText:[item objectForKey:@"title"]];
    [[cell imageView] setImage:[item objectForKey:@"image"]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    /*   if([[[self postInfo] objectForKey:STKPostTypeKey] isEqual:[item objectForKey:STKPostTypeKey]]) {
     [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
     }
     */
    return cell;
}


@end
