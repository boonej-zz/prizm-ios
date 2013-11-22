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

@interface STKHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (nonatomic, strong) UIImage *cardToolbarNormalImage;
@property (nonatomic) float initialCardViewOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewTopOffset;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSMutableArray *reusableCards;
@property (nonatomic, strong) NSMutableDictionary *cardMap;
@property (nonatomic, strong) UINib *homeCellNib;

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
        _cardMap = [[NSMutableDictionary alloc] init];
        _reusableCards = [[NSMutableArray alloc] init];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _initialCardViewOffset = [[self cardViewTopOffset] constant];
    
    _homeCellNib = [UINib nibWithNibName:@"STKHomeCell" bundle:nil];
    [[self tableView] registerNib:_homeCellNib
           forCellReuseIdentifier:@"STKHomeCell"];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setRowHeight:397];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIView *blankView = [[UIView alloc] initWithFrame:[[self cardView] bounds]];
    [blankView setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:blankView];
    
    [[self tableView] setDelaysContentTouches:NO];
    
    _cardToolbarNormalImage = [[UIToolbar appearance] backgroundImageForToolbarPosition:UIBarPositionAny
                                                                             barMetrics:UIBarMetricsDefault];
    [[self cardView] setUserInteractionEnabled:NO];
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
            [[c layer] setShadowColor:[[UIColor blackColor] CGColor]];
            [[c layer] setShadowOffset:CGSizeMake(0, 0)];
            [[c layer] setShadowOpacity:0.75];
            [[c layer] setShadowRadius:5];
        }
        
        [self populateCell:c forIndexPath:ip];
        
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
    float containerHeight = [[self tableView] bounds].size.height - inset.top;
    float totalOffset = offset.y + inset.top;
    float matchLineY = [[self tableView] rowHeight];
    
    // This handles the card area being pushed down in the case of an downwards overscroll
    if(totalOffset < 0) {
        [[self cardViewTopOffset] setConstant:(int)([self initialCardViewOffset] - totalOffset)];
        
        // Make sure cards are in their normal position here.. but they should never not be?
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
            [[c backdropFadeView] setAlpha:t];
        }
        
        
        
        NSIndexPath *lastIndexPathOnScreen = [visibleRows lastObject];
        STKHomeCell *realCell = (STKHomeCell *)[[self tableView] cellForRowAtIndexPath:lastIndexPathOnScreen];
        float lastCellTopRelativeToTable = [realCell frame].origin.y - totalOffset;
        float cellSpan = 30.0;
        if(lastCellTopRelativeToTable <= matchLineY) {
            lastIndexPathOnScreen = [NSIndexPath indexPathForRow:[lastIndexPathOnScreen row] + 1
                                                       inSection:0];
            lastCellTopRelativeToTable += [[self tableView] rowHeight];
        }
        
        
        
        NSIndexPath *indexPath = lastIndexPathOnScreen;
        NSMutableArray *indicesToRepresent = [NSMutableArray array];
        for(int i = 0; i < 3; i++) {
            if([indexPath row] < [[self items] count]) {
                [indicesToRepresent addObject:indexPath];
            }
            
            indexPath = [NSIndexPath indexPathForRow:[indexPath row] + 1
                                           inSection:0];
        }

        
        for(NSIndexPath *ip in indicesToRepresent) {
            STKHomeCell *nextCell = [self cardCellForIndexPath:ip];
            [[self cardView] bringSubviewToFront:nextCell];
            // When at bottom (just came onto screen), t = 1, when at top of cardView, t = 0
 
            float t = (lastCellTopRelativeToTable - matchLineY) / (containerHeight - matchLineY);
            
            if(t > 1.0) {
                t = sqrtf(t);
                [[nextCell layer] setShadowRadius:5.0];
            } else {
                [[nextCell layer] setShadowRadius:t * 5.0];
            }
   
            CGRect r = [nextCell frame];
            r.origin.y = cellSpan * t - 10;
            [nextCell setFrame:r];

            lastCellTopRelativeToTable += [[self tableView] rowHeight];
        }
        
        
        for(NSIndexPath *ip in [[self cardMap] allKeys]) {
            if(![indicesToRepresent containsObject:ip]) {
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

- (void)populateCell:(STKHomeCell *)c forIndexPath:(NSIndexPath *)ip
{
    [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    STKPost *p = [[self items] objectAtIndex:[ip row]];
    [[c iconImageView] setUrlString:[p iconURLString]];
    [[c contentImageView] setUrlString:[p imageURLString]];
    [[c originatorLabel] setText:[p authorName]];
    [[c timeLabel] setText:@"Now"];
    [[c sourceLabel] setText:[p postOrigin]];
    NSMutableString *str = [[NSMutableString alloc] init];
    for(NSString *s in [p hashTags])
        [str appendFormat:@"#%@ ", s];
    [[c hashTagLabel] setText:str];
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
    [[self cardViewTopOffset] setConstant:[self initialCardViewOffset]];
    
    
    [[STKUserStore store] fetchFeedForCurrentUser:^(NSArray *posts, NSError *error, BOOL moreComing) {
        if(!error) {
            if([self items]) {
                _items = [posts arrayByAddingObjectsFromArray:_items];
            } else {
                _items = posts;
            }
            [[self tableView] reloadData];
            [self layoutCards];

        } else {
            
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKHomeCell *c = (STKHomeCell *)[tableView dequeueReusableCellWithIdentifier:@"STKHomeCell"];

    [self populateCell:c forIndexPath:indexPath];
    
    return c;
    
}


@end
