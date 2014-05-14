//
//  STKUserPostListViewController.m
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKUserPostListViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTriImageCell.h"
#import "STKResolvingImageView.h"
#import "STKPost.h"
#import "UIERealTimeBlurView.h"
#import "STKPostController.h"
#import "STKUser.h"
#import "STKContentStore.h"
#import "STKUserStore.h"

@interface STKUserPostListViewController () <UITableViewDelegate, UITableViewDataSource, STKPostControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blurViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *filterBar;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (nonatomic, strong) STKPostController *postController;
@property (nonatomic) BOOL allowPersonalFilter;
@property (weak, nonatomic) IBOutlet UIButton *passionButton;
@property (weak, nonatomic) IBOutlet UIButton *aspirationButton;
@property (weak, nonatomic) IBOutlet UIButton *experienceButton;
@property (weak, nonatomic) IBOutlet UIButton *achivementButton;
@property (weak, nonatomic) IBOutlet UIButton *inspirationButton;
@property (weak, nonatomic) IBOutlet UIButton *personalButton;

@end

@implementation STKUserPostListViewController

- (id)initWithTrust:(STKTrust *)t
{
    self = [self initWithUser:nil];
    if(self) {
        [self setTrust:t];
        [self setShowsFilterBar:NO];
    }
    return self;
}

- (id)initWithUser:(STKUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        [self setUser:user];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        _postController = [[STKPostController alloc] initWithViewController:self];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [self setShowsFilterBar:YES];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithUser:nil];
}


- (void)setUser:(STKUser *)user
{
    _user = user;
    if([[[self user] uniqueID] isEqualToString:[[[STKUserStore store] currentUser] uniqueID]]) {
        [self setAllowPersonalFilter:YES];
    } else {
        [self setAllowPersonalFilter:NO];
    }
}

- (void)deselectAllFilters
{
}

- (void)selectFilter:(UIButton *)sender
{
    BOOL currentlySelected = [sender isSelected];
    for(UIControl *ctl in [[self filterBar] subviews]) {
        [ctl setSelected:NO];
    }
    [sender setSelected:!currentlySelected];
    
    [self reloadPosts];
}

- (IBAction)togglePassions:(UIButton *)sender {
    [self selectFilter:sender];
}
- (IBAction)toggleAspirations:(UIButton *)sender {
    [self selectFilter:sender];
}
- (IBAction)toggleExperiences:(UIButton *)sender {
    [self selectFilter:sender];
}
- (IBAction)toggleAchievements:(UIButton *)sender {
    [self selectFilter:sender];
}
- (IBAction)toggleInspirations:(UIButton *)sender {
    [self selectFilter:sender];
}
- (IBAction)togglePersonal:(UIButton *)sender {
    [self selectFilter:sender];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    if([self allowPersonalFilter]) {
        [[self personalButton] setHidden:NO];
        [[self leftConstraint] setConstant:6];
        [[self rightConstraint] setConstant:6];
    } else {
        [[self personalButton] setHidden:YES];
        [[self leftConstraint] setConstant:6];
        [[self rightConstraint] setConstant:6];
    }

    [[self filterBar] setHidden:![self showsFilterBar]];
    if(![self showsFilterBar]) {
        [[self blurViewHeightConstraint] setConstant:[[self blurViewHeightConstraint] constant] - [[self filterBar] bounds].size.height];
    }
    
    [[self tableView] setRowHeight:106];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    if([self showsFilterBar]) {
        [[self tableView] setContentInset:UIEdgeInsetsMake([[self filterBar] bounds].size.height + [[self filterBar] frame].origin.y, 0, 0, 0)];
    } else {
        [[self tableView] setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    }
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

    
    [self configurePostController];
    
    [self reloadPosts];
}

- (void)configurePostController
{
    __weak STKUserPostListViewController *ws = self;
    if([self user]) {
        [[self postController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchProfilePostsForUser:[ws user] fetchDescription:fs completion:completion];
        }];
    } else if([self trust]) {
        [[self postController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKUserStore store] fetchTrustPostsForTrust:[ws trust] type:[ws trustType] completion:completion];
        }];
    }
    [[self postController] setFilterMap:[self filterDictionary]];
}

- (void)reloadPosts
{
    [self configurePostController];
    [[self tableView] reloadData];
    [[self postController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
}

- (NSDictionary *)filterDictionary
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    if([[self passionButton] isSelected]) {
        [d setObject:STKPostTypePassion forKey:@"type"];
    } else if([[self aspirationButton] isSelected]) {
        [d setObject:STKPostTypeAspiration forKey:@"type"];
    }  else if([[self experienceButton] isSelected]) {
        [d setObject:STKPostTypeExperience forKey:@"type"];
    } else if([[self achivementButton] isSelected]) {
        [d setObject:STKPostTypeAchievement forKey:@"type"];
    } else if([[self inspirationButton] isSelected]) {
        [d setObject:STKPostTypeInspiration forKey:@"type"];
    } else if([[self personalButton] isSelected]) {
        [d setObject:STKPostTypePersonal forKey:@"type"];
    }
    
    return d;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[[self postController] posts] count] % 3 > 0)
        return [[[self postController] posts] count] / 3 + 1;
    return [[[self postController] posts] count] / 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self postController]];
    [c populateWithPosts:[[self postController] posts] indexOffset:[indexPath row] * 3];
//    [[c contentView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    return c;
}

@end