//
//  STKHomeViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKHomeViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKPostCell.h"
#import "STKPost.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKBackdropView.h"
#import "STKContentStore.h"
#import "UIERealTimeBlurView.h"
#import "STKPostViewController.h"
#import "STKProfileViewController.h"
#import "STKCreatePostViewController.h"
#import "STKLocationViewController.h"
#import "STKImageSharer.h"
#import "STKPostController.h"
#import "STKLuminatingBar.h"
#import "STKSearchUsersViewController.h"
#import "STKExploreViewController.h"

@interface STKHomeViewController () <UITableViewDataSource, UITableViewDelegate, STKPostControllerDelegate>

@property (nonatomic, strong) STKPostController *postController;
@property (weak, nonatomic) IBOutlet STKLuminatingBar *luminatingBar;

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *instructionView;

@property (nonatomic, strong) UIImage *cardToolbarNormalImage;
@property (nonatomic) float initialCardViewOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewTopOffset;


@property (nonatomic, strong) NSMutableArray *reusableCards;
@property (nonatomic, strong) NSMutableDictionary *cardMap;
@property (nonatomic, strong) UINib *homeCellNib;

@property (nonatomic, strong) STKBackdropView *backdropView;

@property (nonatomic) BOOL fetchInProgress;

@end

@implementation STKHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_home"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_home_selected"]];
        [[self tabBarItem] setTitle:@"Home"];
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        
        
        [[self navigationItem] setTitle:@"Prizm"];
        
        _postController = [[STKPostController alloc] initWithViewController:self];
        [[self postController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchFeedForUser:[[STKUserStore store] currentUser] fetchDescription:fs completion:completion];
        }];

        [[self view] addSubview:_instructionView];
        _cardMap = [[NSMutableDictionary alloc] init];
        _reusableCards = [[NSMutableArray alloc] init];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _homeCellNib = [UINib nibWithNibName:@"STKPostCell" bundle:nil];
    _initialCardViewOffset = [[self cardViewTopOffset] constant];

    [[self tableView] setDelaysContentTouches:NO];

    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setRowHeight:401];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    UIView *blankView = [[UIView alloc] initWithFrame:[[self cardView] bounds]];
    [blankView setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:blankView];
    
    _cardToolbarNormalImage = [[UIToolbar appearance] backgroundImageForToolbarPosition:UIBarPositionAny
                                                                             barMetrics:UIBarMetricsDefault];
    [[self cardView] setUserInteractionEnabled:NO];
    [[self cardView] setClipsToBounds:NO];
    
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (STKPostCell *)cardCellForIndexPath:(NSIndexPath *)ip
{
    STKPostCell *c = [[self cardMap] objectForKey:ip];
    if(!c) {
        c = [[self reusableCards] lastObject];
        if(c) {
            [[self reusableCards] removeObjectIdenticalTo:c];
        } else {
            c = [[self homeCellNib] instantiateWithOwner:self options:nil][0];
            [c setClipsToBounds:NO];
            [[c layer] setShadowColor:[[UIColor blackColor] CGColor]];
            [[c layer] setShadowOffset:CGSizeMake(0, 0)];
            [[c layer] setShadowOpacity:.4];
        }
        
        [[[c headerView] backdropFadeView] setAlpha:1];
        
        [c populateWithPost:[[[self postController] posts] objectAtIndex:[ip row]]];
        
        CGRect f = [c frame];
        f.origin.x = -10;
        [c setFrame:f];
        
        [[self cardView] addSubview:c];
        [[self cardMap] setObject:c forKey:ip];
    }
    return c;
}

- (UITableViewCell *)postController:(STKPostController *)pc cellForPostAtIndexPath:(NSIndexPath *)ip
{
    return [[self tableView] cellForRowAtIndexPath:ip];
}


- (void)removeCardAndRecycleForIndexPath:(NSIndexPath *)ip
{
    STKPostCell *mimicCell = [[self cardMap] objectForKey:ip];
    if(mimicCell) {
        [mimicCell removeFromSuperview];
        [[self reusableCards] addObject:mimicCell];
        [[self cardMap] removeObjectForKey:ip];
    }
}

- (void)layoutCards
{
    NSArray *visibleRows = [[self tableView] indexPathsForVisibleRows];
    CGPoint offset = [[self tableView] contentOffset];
    UIEdgeInsets inset = [[self tableView] contentInset];
    float totalOffset = offset.y + inset.top;
    
    // This handles the card area being pushed down in the case of an downwards overscroll
    if(totalOffset < 0) {
        [[self cardViewTopOffset] setConstant:(int)([self initialCardViewOffset] - totalOffset)];
    } else {
        [[self cardViewTopOffset] setConstant:[self initialCardViewOffset]];
        
        for(NSIndexPath *ip in visibleRows) {
            // Fade out backdrop image view as cell becomes more visible
            STKPostCell *c = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:ip];
            float y = [c frame].origin.y - totalOffset;
            float t = y - ([[self tableView] rowHeight] - 100);
            if(t < 0)
                t = 0;
            t = (t / 100.0);
            [[[c headerView] backdropFadeView] setAlpha:t];
        }
        
        NSIndexPath *lastIndexPathOnScreen = [visibleRows lastObject];
        STKPostCell *realCell = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:lastIndexPathOnScreen];
        CGRect realCellRect = [[self view] convertRect:[realCell frame] fromView:[self tableView]];
        CGRect cardViewRect = [[self cardView] frame];
        float offsetFromTopOfLastCellToCardView = realCellRect.origin.y - cardViewRect.origin.y + 5.0;
        NSIndexPath *topCardIndexPath = nil;
        
        NSMutableArray *usedPaths = [NSMutableArray array];
        float topCardY = 0.0;
        if(offsetFromTopOfLastCellToCardView > 0.0) {
            // The last cell is underneath the card view
            // We should be tracking the this home cell to the top of the card view
            topCardIndexPath = lastIndexPathOnScreen;
            
            STKPostCell *c = [self cardCellForIndexPath:topCardIndexPath];
            float lowerCardY = [[c headerView] bounds].size.height * 0.4;
            float ratio = offsetFromTopOfLastCellToCardView / [[self cardView] bounds].size.height;

            topCardY = lowerCardY * ratio - 5;
            
            CGRect r = [c frame];
            r.origin.y = topCardY;
            [c setFrame:r];
            [[c layer] setShadowRadius:ratio * 5];
            
            [usedPaths addObject:topCardIndexPath];
            
        } else {
            // The last cell is above the card view
            // The next cell should be fixed to the top of the card view
            topCardIndexPath = [NSIndexPath indexPathForRow:[lastIndexPathOnScreen row] + 1
                                                  inSection:0];
            if([topCardIndexPath row] < [[[self postController] posts] count]) {
                STKPostCell *c = [self cardCellForIndexPath:topCardIndexPath];
                
                float lowerCardY = [[c headerView] bounds].size.height * 0.8;
                float upperCardY = [[c headerView] bounds].size.height * 0.4;
                float lastCellOffsetFromBottom = [[self view] bounds].size.height - (realCellRect.origin.y + realCellRect.size.height);
                float ratio = (fabs(lastCellOffsetFromBottom) / 299.0);

                topCardY = upperCardY + (lowerCardY - upperCardY) * ratio - 5;

                CGRect r = [c frame];
                r.origin.y = topCardY;
                [c setFrame:r];
                
                [[c layer] setShadowRadius:(1.0 - ratio) * 3 + 5];

                [usedPaths addObject:topCardIndexPath];
            }
        }

        float diminishingY = 0.7;
        for(int i = 0; i < 2; i++) {
            topCardIndexPath = [NSIndexPath indexPathForRow:[topCardIndexPath row] + 1 inSection:0];
            if([topCardIndexPath row] < [[[self postController] posts] count]) {
                STKPostCell *c = [self cardCellForIndexPath:topCardIndexPath];
                [[c layer] setShadowRadius:8];
                [[c superview] bringSubviewToFront:c];
                CGRect r = [c frame];
                r.origin.y = topCardY + [[c headerView] bounds].size.height * diminishingY;
                [c setFrame:r];
                [usedPaths addObject:topCardIndexPath];

                topCardY = r.origin.y;
            }
        }
        
        for(NSIndexPath *ip in [[self cardMap] allKeys]) {
            if(![usedPaths containsObject:ip]) {
                [self removeCardAndRecycleForIndexPath:ip];
            }
        }
    }
    [[self cardView] layoutIfNeeded];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self layoutCards];
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
        [self fetchOlderPosts];
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < -60) {
        [self fetchNewPosts];
    }
}

- (void)fetchOlderPosts
{
    if([self fetchInProgress]) {
        return;
    }
    [self setFetchInProgress:YES];
    
    [[self postController] fetchOlderPostsWithCompletion:^(NSArray *newPosts, NSError *err) {
        [self setFetchInProgress:NO];
        [[self tableView] reloadData];
        [self layoutCards];
    }];
}

- (void)fetchNewPosts
{
    if([self fetchInProgress]) {
        return;
    }
    
    [self setFetchInProgress:YES];

    [[self luminatingBar] setLuminating:YES];
    [[self postController] fetchNewerPostsWithCompletion:^(NSArray *newPosts, NSError *err) {
        [self setFetchInProgress:NO];
        [[self luminatingBar] setLuminating:NO];
        [[self tableView] reloadData];
        [self layoutCards];
    }];
}

- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx
{
    STKPostCell *c = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];

    return [[self view] convertRect:[[c contentImageView] frame]
                           fromView:[[c contentImageView] superview]];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([[[STKUserStore store] currentUser] followingCount] > 0) {
        [[self instructionView] setHidden:YES];
    } else {
        [[self instructionView] setHidden:NO];
    }
    
    [[[self blurView] displayLink] setPaused:NO];
    
    [[self cardViewTopOffset] setConstant:[self initialCardViewOffset]];

    if([[STKUserStore store] currentUser]) {
        [self fetchNewPosts];
    }
}

- (void)menuWillAppear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.5];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self postController] posts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKPostCell *c = [STKPostCell cellForTableView:tableView target:[self postController]];

    [c populateWithPost:[[[self postController] posts] objectAtIndex:[indexPath row]]];
    
    return c;
}

- (IBAction)findFriends:(id)sender
{
    STKSearchUsersViewController *stvc = [[STKSearchUsersViewController alloc] initWithSearchType:STKSearchUsersToFollow];
    [[self navigationController] pushViewController:stvc animated:YES];
}

- (IBAction)stuffWeLike:(id)sender
{
    UINavigationController *nvc = (UINavigationController *)[[self menuController] childViewControllerForType:[STKExploreViewController class]];
    STKExploreViewController *vc = [[nvc viewControllers] firstObject];
    [vc setExploreType:STKExploreTypeFeatured];
    [[self menuController] setSelectedViewController:nvc];
}

- (IBAction)trending:(id)sender
{
    UINavigationController *nvc = (UINavigationController *)[[self menuController] childViewControllerForType:[STKExploreViewController class]];
    STKExploreViewController *vc = [[nvc viewControllers] firstObject];
    [vc setExploreType:STKExploreTypePopular];
    [[self menuController] setSelectedViewController:nvc];
}


@end
