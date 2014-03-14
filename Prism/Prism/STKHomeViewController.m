//
//  STKHomeViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKHomeViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKHomeCell.h"
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

@interface STKHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (nonatomic, strong) UIImage *cardToolbarNormalImage;
@property (nonatomic) float initialCardViewOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewTopOffset;


@property (nonatomic, strong) NSMutableArray *reusableCards;
@property (nonatomic, strong) NSMutableDictionary *cardMap;
@property (nonatomic, strong) UINib *homeCellNib;

@property (nonatomic, strong) STKBackdropView *backdropView;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation STKHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_home"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_home_selected"]];
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        
        [[self navigationItem] setTitle:@"Prism"];
        
        _cardMap = [[NSMutableDictionary alloc] init];
        _reusableCards = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] init];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _homeCellNib = [UINib nibWithNibName:@"STKHomeCell" bundle:nil];
    _initialCardViewOffset = [[self cardViewTopOffset] constant];
    
    [[self tableView] registerNib:_homeCellNib
           forCellReuseIdentifier:@"STKHomeCell"];
    [[self tableView] setDelaysContentTouches:NO];

    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setRowHeight:401];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    UIView *blankView = [[UIView alloc] initWithFrame:[[self cardView] bounds]];
    [blankView setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:blankView];
    
    _cardToolbarNormalImage = [[UIToolbar appearance] backgroundImageForToolbarPosition:UIBarPositionAny
                                                                             barMetrics:UIBarMetricsDefault];
    [[self cardView] setUserInteractionEnabled:NO];
    [[self cardView] setClipsToBounds:NO];
    
}

- (STKHomeCell *)cardCellForIndexPath:(NSIndexPath *)ip
{
    STKHomeCell *c = [[self cardMap] objectForKey:ip];
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
//            [[c layer] setShadowRadius:];
        }
        
        [[[c headerView] backdropFadeView] setAlpha:1];
        
        [c populateWithPost:[[self items] objectAtIndex:[ip row]]];
        
        CGRect f = [c frame];
        f.origin.x = -10;
        [c setFrame:f];
        
        [[self cardView] addSubview:c];
        [[self cardMap] setObject:c forKey:ip];
    }
    return c;
}


- (void)removeCardAndRecycleForIndexPath:(NSIndexPath *)ip
{
    STKHomeCell *mimicCell = [[self cardMap] objectForKey:ip];
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
            STKHomeCell *c = (STKHomeCell *)[[self tableView] cellForRowAtIndexPath:ip];
            float y = [c frame].origin.y - totalOffset;
            float t = y - ([[self tableView] rowHeight] - 100);
            if(t < 0)
                t = 0;
            t = (t / 100.0);
            [[[c headerView] backdropFadeView] setAlpha:t];
        }
        
        NSIndexPath *lastIndexPathOnScreen = [visibleRows lastObject];
        STKHomeCell *realCell = (STKHomeCell *)[[self tableView] cellForRowAtIndexPath:lastIndexPathOnScreen];
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
            
            STKHomeCell *c = [self cardCellForIndexPath:topCardIndexPath];
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
            if([topCardIndexPath row] < [[self items] count]) {
                STKHomeCell *c = [self cardCellForIndexPath:topCardIndexPath];
                
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
            if([topCardIndexPath row] < [[self items] count]) {
                STKHomeCell *c = [self cardCellForIndexPath:topCardIndexPath];
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
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self items] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self blurView] displayLink] setPaused:NO];
    
    [[self cardViewTopOffset] setConstant:[self initialCardViewOffset]];
    
    NSArray *deletedPosts = [[self items] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %@", STKPostStatusDeleted]];
    [[self items] removeObjectsInArray:deletedPosts];

    if([[STKUserStore store] currentUser]) {
        [[STKContentStore store] fetchFeedForUser:[[STKUserStore store] currentUser]
                                      inDirection:STKContentStoreFetchDirectionNewer
                                    referencePost:[[self items] firstObject] completion:^(NSArray *posts, NSError *err) {
                                        if(!err) {
                                            [[self items] addObjectsFromArray:posts];
                                            [[self items] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
                                            [[self tableView] reloadData];
                                            [self layoutCards];
                                        } else {
                                            
                                        }
                                    }];
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

- (void)showComments:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *post = [[self items] objectAtIndex:[ip row]];
    [self showPost:post];
}

- (void)imageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *post = [[self items] objectAtIndex:[ip row]];
    [self showPost:post];
}

- (void)showPost:(STKPost *)p
{
    NSInteger idx = [[self items] indexOfObject:p];
    STKHomeCell *c = (STKHomeCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    
    
    [[self menuController] transitionToPost:p
                                   fromRect:[[self view] convertRect:[[c contentImageView] frame] fromView:[[c contentImageView] superview]]
                           inViewController:self
                                   animated:YES];
}

- (void)addToPrism:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKCreatePostViewController *pvc = [[STKCreatePostViewController alloc] init];
    [pvc setImageURLString:[[[self items] objectAtIndex:[ip row]] imageURLString]];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];

    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)sharePost:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [[self items] objectAtIndex:[ip row]];
    STKHomeCell *c = (STKHomeCell *)[[self tableView] cellForRowAtIndexPath:ip];
    UIActivityViewController *vc = [[STKImageSharer defaultSharer] activityViewControllerForImage:[[c contentImageView] image]
                                                                                             text:[p text]
                                                                                    finishHandler:^(UIDocumentInteractionController *doc) {
                                                                                        [doc presentOpenInMenuFromRect:[[self view] bounds] inView:[self view] animated:YES];
                                                                                    }];
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)showLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [[self items] objectAtIndex:[ip row]];
    if([p locationName]) {
        STKLocationViewController *lvc = [[STKLocationViewController alloc] init];
        [lvc setCoordinate:[p coordinate]];
        [lvc setLocationName:[p locationName]];
        [[self navigationController] pushViewController:lvc animated:YES];
    }
}

- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    
    STKPost *p = [[self items] objectAtIndex:[ip row]];
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:[p creator]];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)toggleLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *post = [[self items] objectAtIndex:[ip row]];
    if([post postLikedByCurrentUser]) {
        [[STKContentStore store] unlikePost:post
                                 completion:^(STKPost *p, NSError *err) {
                                     [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                             withRowAnimation:UITableViewRowAnimationNone];
                                 }];
    } else {
        [[STKContentStore store] likePost:post
                               completion:^(STKPost *p, NSError *err) {
                                   [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                           withRowAnimation:UITableViewRowAnimationNone];
                               }];
    }
    [[self tableView] reloadRowsAtIndexPaths:@[ip]
                            withRowAnimation:UITableViewRowAnimationNone];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKHomeCell *c = [STKHomeCell cellForTableView:tableView target:self];

    [c populateWithPost:[[self items] objectAtIndex:[indexPath row]]];
    
    return c;
}


@end
