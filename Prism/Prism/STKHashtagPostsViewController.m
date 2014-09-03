//
//  STKHashtagPostsViewController.m
//  Prism
//
//  Created by Joe Conway on 4/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKHashtagPostsViewController.h"
#import "STKTriImageCell.h"
#import "STKPostController.h"
#import "STKContentStore.h"
#import "UIERealTimeBlurView.h"
#import "STKResolvingImageView.h"
#import "STKPostCell.h"
#import "UIViewController+STKControllerItems.h"

@interface STKHashtagPostsViewController () <STKPostControllerDelegate>

@property (nonatomic, weak) IBOutlet UIERealTimeBlurView *blurView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *barLabel;
@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, strong) STKPostController *hashTagPostsController;
@property (nonatomic) BOOL showPostsInSingleLayout;

- (IBAction)gridViewButtonTapped:(id)sender;
- (IBAction)cardViewButtonTapped:(id)sender;

@end

@implementation STKHashtagPostsViewController

- (id)initWithHashTag:(NSString *)hashTag
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [self setHashTag:hashTag];
        _hashTagPostsController = [[STKPostController alloc] initWithViewController:self];
        
        [[self hashTagPostsController] setFilterMap:@{@"hashTags": hashTag}];
        [[self hashTagPostsController] setFetchMechanism:^(STKFetchDescription *fd, void (^comp)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fd completion:comp];
        }];
    }
    return self;
}

- (UIViewController *)viewControllerForPresentingPostInPostController:(STKPostController *)pc
{
    return [[self navigationController] parentViewController];
}

- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx
{
    if([self showPostsInSingleLayout]){
        STKPostCell *cell = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
        return [[self view] convertRect:[[cell contentView] frame] fromView:[[cell contentImageView] superview]];
        
    }else{
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *hashTagTitle = [NSString stringWithFormat:@"#%@", [self hashTag]];
    
    [[self barLabel] setText:[self hashTagCount]];
    [[[[self parentViewController] parentViewController] navigationItem] setTitle:hashTagTitle];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setContentInset:UIEdgeInsetsMake(109, 0, 0, 0)];
    
}

- (IBAction)gridViewButtonTapped:(id)sender
{
    [self setShowPostsInSingleLayout:NO];
    [[self tableView] reloadData];
}

- (IBAction)cardViewButtonTapped:(id)sender
{
    [self setShowPostsInSingleLayout:YES];
    [[self tableView] reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    
    [[self hashTagPostsController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
    
    [[[[self parentViewController] parentViewController] navigationItem] setLeftBarButtonItem:[self backButtonItem]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    long postCount = [[[self hashTagPostsController] posts] count];

    if([self showPostsInSingleLayout]) {
        return postCount;
    } else {
        if(postCount % 3 > 0)
            return postCount / 3 + 1;
        
        return postCount / 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self showPostsInSingleLayout]){
        STKPostCell *cell = [STKPostCell cellForTableView:tableView target:[self hashTagPostsController]];
        [cell populateWithPost:[[[self hashTagPostsController] posts] objectAtIndex:[indexPath row]]];
        
        return cell;
        
    }else{
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self hashTagPostsController]];
        [c populateWithPosts:[[self hashTagPostsController] posts] indexOffset:([indexPath row]) * 3];
        
        return c;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([self showPostsInSingleLayout]){
        return 401;
    }
    return 106.0;
}

@end
