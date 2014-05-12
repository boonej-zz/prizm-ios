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

@interface STKHashtagPostsViewController () <STKPostControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backButtonImageView;
@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, strong) STKPostController *hashTagPostsController;
@property (nonatomic, weak) IBOutlet UIERealTimeBlurView *blurView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *barLabel;

- (IBAction)backBarTapped:(id)sender;

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

    [[self barLabel] setText:[NSString stringWithFormat:@"#%@", [self hashTag]]];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setContentInset:UIEdgeInsetsMake(109, 0, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    
    [[self hashTagPostsController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
    [[self backButtonImageView] setHidden:![self showsOwnBackButton]];
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
    int postCount = [[[self hashTagPostsController] posts] count];

    if(postCount % 3 > 0)
        return postCount / 3 + 1;
    
    return postCount / 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self hashTagPostsController]];
    [c populateWithPosts:[[self hashTagPostsController] posts] indexOffset:([indexPath row]) * 3];
    
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106.0;
}


- (IBAction)backBarTapped:(id)sender
{
    if([self showsOwnBackButton])
        [[self navigationController] popViewControllerAnimated:YES];
}
@end
