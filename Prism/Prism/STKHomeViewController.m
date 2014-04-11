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

@interface STKHomeViewController () <UITableViewDataSource, UITableViewDelegate, STKPostControllerDelegate>

@property (nonatomic, strong) STKPostController *postController;

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
        
        [[self navigationItem] setTitle:@"Prizm"];
        
        _postController = [[STKPostController alloc] initWithViewController:self];
        
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
//            [[c layer] setShadowRadius:];
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
    
    [[[self blurView] displayLink] setPaused:NO];
    
    [[self cardViewTopOffset] setConstant:[self initialCardViewOffset]];

    if([[STKUserStore store] currentUser]) {
        [[STKContentStore store] fetchFeedForUser:[[STKUserStore store] currentUser]
                                      inDirection:STKQueryObjectPageNewer
                                    referencePost:[[[self postController] posts] firstObject]
                                       completion:^(NSArray *posts, NSError *err) {
                                        if(!err) {
                                            [[self postController] addPosts:posts];
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


@end
