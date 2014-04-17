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
#import "STKSearchHashTagsCell.h"

typedef enum {
    STKExploreTypeLatest = 0,
    STKExploreTypePopular = 1
} STKExploreType;

typedef enum {
    STKSearchTypeUser = 0,
    STKSearchTypeHashTag = 1,
    STKSearchTypeHashTagPosts = 2
} STKSearchType;

@interface STKExploreViewController ()
    <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STKPostControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *filterPostOptions;

@property (nonatomic, strong) STKPostController *recentPostsController;
@property (nonatomic, strong) STKPostController *popularPostsController;
@property (nonatomic, strong) STKPostController *featuredPostsController;
@property (nonatomic, assign) STKPostController *activePostController;
@property (nonatomic, strong) STKPostController *hashTagPostsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *exploreTypeControl;
@property (nonatomic, strong) IBOutlet UIERealTimeBlurView *blurView;

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *filterOptionView;

@property (weak, nonatomic) IBOutlet UIView *searchContainer;

@property (nonatomic) STKSearchType searchType;
@property (nonatomic, strong) NSArray *profilesFound;
@property (nonatomic, strong) NSArray *hashTagsFound;
@property (nonatomic, strong) STKNavigationButton *searchButton;
@property (nonatomic, strong) UIBarButtonItem *searchButtonItem;

- (IBAction)exploreTypeChanged:(id)sender;
- (IBAction)toggleFilterView:(id)sender;

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
        _featuredPostsController = [[STKPostController alloc] initWithViewController:self];
        _hashTagPostsController = [[STKPostController alloc] initWithViewController:self];
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

- (IBAction)searchTypeChanged:(UISegmentedControl *)sender
{
    if([sender selectedSegmentIndex] == 0) {
        [self setSearchType:STKSearchTypeUser];
    } else {
        [self setSearchType:STKSearchTypeHashTag];
    }
    
    [self setHashTagsFound:nil];
    [self setProfilesFound:nil];
    [self reloadSearchResults];
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
        filter = @{@"sort_by" : @"likes_count", @"sort" : @"-1"};
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

    if([self searchType] == STKSearchTypeUser)
        [[self searchTypeControl] setSelectedSegmentIndex:0];
    else
        [[self searchTypeControl] setSelectedSegmentIndex:1];
    
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
    if([cell isKindOfClass:[STKSearchProfileCell class]] || [cell isKindOfClass:[STKSearchHashTagsCell class]]) {
        [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
    } else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self tableView])
        return [[self tableView] rowHeight];
    
    if([self searchType] == STKSearchTypeHashTagPosts) {
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
        return [[self hashTagsFound] count];
    
    if([self searchType] == STKSearchTypeHashTagPosts)
        return [[[self hashTagPostsController] posts] count];
    
    return [[self profilesFound] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self tableView]) {
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self activePostController]];
        [c populateWithPosts:[[self activePostController] posts] indexOffset:[indexPath row] * 3];
        return c;
    }
    
    if([self searchType] == STKSearchTypeHashTagPosts){
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self hashTagPostsController]];
        [c populateWithPosts:[[self hashTagPostsController] posts] indexOffset:[indexPath row] * 3];
        
        return c;
    }

    if([self searchType] == STKSearchTypeHashTag){
        STKSearchHashTagsCell *c = [STKSearchHashTagsCell cellForTableView:tableView target:self];
        NSDictionary *hashtag = [[self hashTagsFound] objectAtIndex:[indexPath row]];
        [[c hashTagLabel] setText:[NSString stringWithFormat:@"#%@",[hashtag objectForKey:@"hash_tag"]]];
        [[c count] setText:[NSString stringWithFormat:@"%@",[hashtag objectForKey:@"count"]]];
        
        return c;
    }
    
    STKSearchProfileCell *c = [STKSearchProfileCell cellForTableView:tableView target:self];
    STKUser *u = [[self profilesFound] objectAtIndex:[indexPath row]];
    [[c nameLabel] setTextColor:STKTextColor];
    [[c nameLabel] setText:[u name]];
    [[c avatarView] setUrlString:[u profilePhotoPath]];

    if([u isEqual:[[STKUserStore store] currentUser]]) {
        [[c followButton] setHidden:YES];
    } else {
        [[c followButton] setHidden:NO];
        if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
            [[c followButton] setSelected:YES];
        } else {
            [[c followButton] setSelected:NO];
        }
    }

    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self searchResultsTableView]) {
        if([self searchType] == STKSearchTypeUser){
            STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
            [pvc setProfile:[[self profilesFound] objectAtIndex:[indexPath row]]];
            [[self navigationController] pushViewController:pvc animated:YES];
        }
        
        if([self searchType] == STKSearchTypeHashTag) {
            NSDictionary *hashtag = [[self hashTagsFound] objectAtIndex:[indexPath row]];
            if([hashtag objectForKey:@"hash_tag"]) {
                STKPostController *pc = [self hashTagPostsController];
                [[STKContentStore store] fetchExplorePostsForHashTag:[hashtag objectForKey:@"hash_tag"]
                                                         inDirection:STKQueryObjectPageNewer
                                                       referencePost:nil
                                                          completion:^(NSArray *posts, NSError *err) {
                                                              if(!err && posts) {
                                                                  [pc setPosts:(NSMutableArray*)[posts mutableCopy]];
                                                                  [self setSearchType:STKSearchTypeHashTagPosts];
                                                                  [self reloadSearchResults];
                                                              }
                }];
            }
        }
    }
}


- (IBAction)searchFieldDidChange:(UITextField *)sender
{
    if([self searchType] == STKSearchTypeHashTagPosts)
        [self setSearchType:STKSearchTypeHashTag];
    
    NSString *searchString = [sender text];
    if([searchString length] < 2) {
        [self reloadSearchResults];
        return;
    }
    if([self searchType] == STKSearchTypeHashTag) {
        [[STKContentStore store] searchPostsForHashtag:searchString completion:^(NSArray *hashtags, NSError *err) {
            [self setHashTagsFound:hashtags];
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
    [self setHashTagsFound:nil];
    [[self hashTagPostsController] setPosts:nil];
    [self reloadSearchResults];
    return YES;
}

- (void)reloadSearchResults
{
    if([self searchType] == STKSearchTypeHashTag) {
        
        [[self searchResultsTableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

        if([[self hashTagsFound] count] == 0) {
            [[self searchResultsTableView] setHidden:YES];
        } else {
            [[self searchResultsTableView] setHidden:NO];
        }
        
    } else if ([self searchType] == STKSearchTypeHashTagPosts) {
        
        [[self searchResultsTableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        if([[[self hashTagPostsController] posts] count] == 0){
            [[self searchResultsTableView] setHidden:YES];
        }else{
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
