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
#import "STKPostViewController.h"
#import "STKUser.h"
#import "STKUserStore.h"

@interface STKHashtagPostsViewController () <STKPostControllerDelegate, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIERealTimeBlurView *blurView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *barLabel;
@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, strong) STKPostController *postsController;

@property (nonatomic) BOOL showPostsInSingleLayout;
@property (nonatomic) BOOL isLikesPage;

@property (nonatomic, weak) IBOutlet UIControl *toolbarControl;


- (IBAction)gridViewButtonTapped:(id)sender;
- (IBAction)cardViewButtonTapped:(id)sender;

@end

@implementation STKHashtagPostsViewController

- (id)initWithHashTag:(NSString *)hashTag
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [self setHashTag:hashTag];
        _postsController = [[STKPostController alloc] initWithViewController:self];
        NSSortDescriptor *recent = [NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO];
        [[self postsController] setSortDescriptors:@[recent]];
        [[self postsController] setFilterMap:@{@"hashTags": hashTag}];
        [[self postsController] setFetchMechanism:^(STKFetchDescription *fd, void (^comp)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchExplorePostsWithFetchDescription:fd completion:comp];
        }];
    }
    return self;
}

- (id)initForLikes
{
    self = [super initWithNibName:nil bundle:nil];
    if (self){
        _postsController = [[STKPostController alloc] initWithViewController:self];
        STKUser *user = [[STKUserStore store] currentUser];
        _isLikesPage = YES;
        
        [[self postsController] setFetchMechanism:^(STKFetchDescription *fd, void (^comp)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchLikedPostsForUser:user fetchDescription:fd completion:comp];
        }];
    }
    return self;
}

- (UIViewController *)viewControllerForPresentingPostInPostController:(STKPostController *)pc
{

    if ([self isLinkedToPost] || [self isLikesPage]) {
        return [self.navigationController.viewControllers objectAtIndex:1];
    }
    
    return self.navigationController.parentViewController;
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
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage HABackgroundImage]];
    [iv setFrame:[self.view bounds]];
    [self.view insertSubview:iv atIndex:0];
    
    
    [[self barLabel] setText:[self hashTagCount]];
    
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setContentInset:UIEdgeInsetsMake(109, 0, 0, 0)];
    [self addBlurViewWithHeight:109.f];
    [self.view bringSubviewToFront:self.toolbarControl];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [self.navigationItem setLeftBarButtonItem:bbi];
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    [[self postsController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
    if (self.isLikesPage) {
        [self setTitle:@"Likes"];
    } else {
        NSString *hashTagTitle = [NSString stringWithFormat:@"#%@", [self hashTag]];
        [self setTitle:hashTagTitle];
        [[[[self parentViewController] parentViewController] navigationItem] setTitle:hashTagTitle];
    }
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
    long postCount = [[[self postsController] posts] count];

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
        STKPostCell *cell = [STKPostCell cellForTableView:tableView target:[self postsController]];
        [cell populateWithPost:[[[self postsController] posts] objectAtIndex:[indexPath row]]];
        
        return cell;
        
    }else{
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self postsController]];
        [c populateWithPosts:[[self postsController] posts] indexOffset:([indexPath row]) * 3];
        
        return c;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKPost *post = [[[self postsController] posts] objectAtIndex:[indexPath row]];
    STKPostViewController *pvc = [[STKPostViewController alloc] init];
    [pvc setPost:post];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([self showPostsInSingleLayout]){
        return 401;
    }
    return 106.0;
}

- (void)fetchNewPosts
{
//    [[self luminatingBar] setLuminating:YES];
//    [self configurePostController];
    [[self tableView] reloadData];
    [[self postsController] fetchNewerPostsWithCompletion:^(NSArray *newPosts, NSError *err) {
//        [[self luminatingBar] setLuminating:NO];
        [[self tableView] reloadData];
    }];
    
}

- (void)fetchOlderPosts
{
//    [self configurePostController];
    [[self tableView] reloadData];
    [[self postsController] fetchOlderPostsWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
    
}

- (void)reloadPosts
{
//    [[self luminatingBar] setLuminating:YES];
//    [self configurePostController];
    [[self tableView] reloadData];
    [[self postsController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
//        [[self luminatingBar] setLuminating:NO];
        [[self tableView] reloadData];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < 0) {
        float t = fabs(offset) / 60.0;
        if(t > 1)
            t = 1;
//        [[self luminatingBar] setProgress:t];
    } else {
//        [[self luminatingBar] setProgress:0];
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


@end
