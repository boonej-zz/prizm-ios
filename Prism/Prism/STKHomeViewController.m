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

@interface STKHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (nonatomic, strong) NSArray *cardedCells;
@property (nonatomic, strong) UIImage *cardToolbarFadeImage;
@property (nonatomic, strong) UIImage *cardToolbarNormalImage;
@property (nonatomic) float initialCardViewOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewTopOffset;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _initialCardViewOffset = [[self cardViewTopOffset] constant];
    
    UINib *nib = [UINib nibWithNibName:@"STKHomeCell" bundle:nil];
    [[self tableView] registerNib:nib
           forCellReuseIdentifier:@"STKHomeCell"];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setRowHeight:397];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIView *blankView = [[UIView alloc] initWithFrame:[[self cardView] bounds]];
    [blankView setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:blankView];
    
    
    _cardedCells = @[[[nib instantiateWithOwner:self options:nil] objectAtIndex:0],
                     [[nib instantiateWithOwner:self options:nil] objectAtIndex:0],
                     [[nib instantiateWithOwner:self options:nil] objectAtIndex:0]];
    

    UIGraphicsBeginImageContext(CGSizeMake(2, 2));
    [[UIColor colorWithRed:0.06 green:0.15 blue:0.40 alpha:0.95] set];
    UIRectFill(CGRectMake(0, 0, 2, 2));
    _cardToolbarFadeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _cardToolbarNormalImage = [[UIToolbar appearance] backgroundImageForToolbarPosition:UIBarPositionAny
                                                                             barMetrics:UIBarMetricsDefault];
    
    for(STKHomeCell *c in [self cardedCells]) {
        CGRect f = [c frame];
        f.origin.x = -10;
        [c setFrame:f];
        
        [[c layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[c layer] setShadowOffset:CGSizeMake(0, 0)];
        [[c layer] setShadowOpacity:0.5];
        [[c layer] setShadowRadius:5];
        [[c topToolbar] setBackgroundImage:[self cardToolbarFadeImage]
                        forToolbarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
        [self populateCell:c forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        [[self cardView] addSubview:c];
    }
    [[self cardView] setUserInteractionEnabled:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self cardViewTopOffset] setConstant:[self initialCardViewOffset]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // This really needs to be optimized
    CGPoint offset = [scrollView contentOffset];
    UIEdgeInsets inset = [scrollView contentInset];
    
    float totalOffset = offset.y + inset.top;
    
    // This handles the card area being pushed down in the case of an downwards overscroll
    if(totalOffset < 0) {
        [[self cardViewTopOffset] setConstant:[self initialCardViewOffset] - totalOffset];
        
        // Make sure cards are in their normal position here.. but they should never not be?
    } else {
        [[self cardViewTopOffset] setConstant:[self initialCardViewOffset]];
        
        // Here, cards can be an accordion position
        int rowOffset = (int)totalOffset % ((int)[[self tableView] rowHeight]);
        float t = (float)rowOffset / ([[self tableView] rowHeight] - 1);
        int index = 0;
        for(STKHomeCell *c in [self cardedCells]) {
            CGRect r = [c frame];
            
            r.origin.y = 20 - 30.0 * t + index * 34;
            [c setFrame:r];
            if(index == 0)
                [[c layer] setShadowRadius:5.0 * (1.0 - t)];
            else
                [[c layer] setShadowRadius:5.0];
            index ++;
        }
    }
    [[self cardView] layoutIfNeeded];

    
    for(STKHomeCell *c in [[self tableView] visibleCells]) {
        float y = [c frame].origin.y - totalOffset;
        float t = y - ([[self tableView] rowHeight] - 100);
        if(t < 0)
            t = 0;
        
        t = (t / 100.0);
        
        [[c backdropFadeView] setAlpha:t];
        
    }
}

- (void)populateCell:(STKHomeCell *)c forIndexPath:(NSIndexPath *)ip
{
    if(![[c backdropFadeView] image]) {
        [[c backdropFadeView] setImage:[self cardToolbarFadeImage]];
    }
    
    [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[c iconImageView] setImage:[UIImage imageNamed:@"wisconsin"]];
    [[c contentImageView] setImage:[UIImage imageNamed:@"19"]];
    [[c originatorLabel] setText:@"University of Wisconsin"];
    [[c timeLabel] setText:@"2hrs"];
    [[c sourceLabel] setText:@"Post via Instagram"];
    [[c hashTagLabel] setText:@"#domination #bestschoolever"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKHomeCell *c = (STKHomeCell *)[tableView dequeueReusableCellWithIdentifier:@"STKHomeCell"];

    [self populateCell:c forIndexPath:indexPath];
    
    return c;
    
}

@end
