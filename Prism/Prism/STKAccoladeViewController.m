//
//  STKAccoladeViewController.m
//  Prism
//
//  Created by Joe Conway on 5/23/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKAccoladeViewController.h"
#import "UIERealTimeBlurView.h"
#import "STKLuminatingBar.h"
#import "STKSegmentedControl.h"
#import "STKActivityCell.h"
#import "STKCreateAccoladeViewController.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKPostController.h"
#import "STKContentStore.h"
#import "STKRelativeDateConverter.h"
#import "STKProfileViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTriImageCell.h"

typedef enum {
    STKAccoladeTypeReceived,
    STKAccoladeTypeSent
} STKAccoladeType;

@interface STKAccoladeViewController () <UITableViewDataSource, UITableViewDelegate, STKPostControllerDelegate>

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet STKLuminatingBar *luminatingBar;
@property (weak, nonatomic) IBOutlet STKSegmentedControl *typeControl;


@property (nonatomic) STKAccoladeType type;

@property (nonatomic, strong) STKPostController *receivedPostController;
@property (nonatomic, strong) STKPostController *sentPostController;

@end

@implementation STKAccoladeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setTitle:@"Accolades"];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"post_accolades"] style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(postAccolade:)];
        [bbi setBackgroundVerticalPositionAdjustment:1 forBarMetrics:UIBarMetricsDefault];
        [[self navigationItem] setRightBarButtonItem:bbi];

        __weak STKAccoladeViewController *ws = self;

        _receivedPostController = [[STKPostController alloc] initWithViewController:self];
        [[self receivedPostController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchProfilePostsForUser:[ws user] fetchDescription:fs completion:completion];
        }];

        _sentPostController = [[STKPostController alloc] initWithViewController:self];
        [[self sentPostController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchProfilePostsForUser:[ws user] fetchDescription:fs completion:completion];
        }];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setRowHeight:106];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(64 + 50, 0, 0, 0)];
}

- (void)postAccolade:(id)sender
{
    STKCreateAccoladeViewController *avc = [[STKCreateAccoladeViewController alloc] init];
    [avc setUser:[self user]];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)reloadAccolades
{
    if([self type] == STKAccoladeTypeSent) {
        [[self sentPostController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
            [[self tableView] reloadData];
        }];
    } else {
        [[self receivedPostController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
            [[self tableView] reloadData];
        }];
    }

    [[self tableView] reloadData];
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([[[self user] uniqueID] isEqualToString:[[[STKUserStore store] currentUser] uniqueID]]) {
        [[self navigationItem] setRightBarButtonItem:nil];
    }
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

    [[[self blurView] displayLink] setPaused:NO];

    [[self receivedPostController] setFilterMap:@{@"accoladeReceiver" : [[self user] uniqueID], @"type" : STKPostTypeAccolade}];
    [[self sentPostController] setFilterMap:@{@"creator" : [[self user] uniqueID], @"type" : STKPostTypeAccolade}];

    [self reloadAccolades];
    
}

- (void)profileImageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [self postForIndexPath:ip];
    if([p creator]) {
        STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
        [pvc setProfile:[p creator]];
        [[self navigationController] pushViewController:pvc animated:YES];
    }
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

- (IBAction)typeChanged:(id)sender
{
    if([sender selectedSegmentIndex] == 0) {
        [self setType:STKAccoladeTypeReceived];
    } else if([sender selectedSegmentIndex]) {
        [self setType:STKAccoladeTypeSent];
    }
    
    [self reloadAccolades];
}

- (STKPost *)postForIndexPath:(NSIndexPath *)ip
{
    if([self type] == STKAccoladeTypeSent) {
        return [[[self sentPostController] posts] objectAtIndex:[ip row]];
    } else {
        return [[[self receivedPostController] posts] objectAtIndex:[ip row]];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKPost *p = [self postForIndexPath:indexPath];
    STKActivityCell *c = (STKActivityCell *)[tableView cellForRowAtIndexPath:indexPath];
    [[self menuController] transitionToPost:p
                                   fromRect:[[self view] convertRect:[[c imageReferenceView] frame] fromView:c]
                                 usingImage:[[c imageReferenceView] image]
                           inViewController:self
                                   animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    STKPostController *a = [self sentPostController];
    if([self type] == STKAccoladeTypeReceived)
        a = [self receivedPostController];

    int postCount = [[a posts] count];
    if(postCount % 3 > 0)
        return postCount / 3 + 1;
    return postCount / 3;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKPostController *a = [self sentPostController];
    if([self type] == STKAccoladeTypeReceived)
        a = [self receivedPostController];

    STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:a];
    [c populateWithPosts:[a posts] indexOffset:[indexPath row] * 3];
    return c;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
//        [self fetchOlderItems];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < -60) {
//        [self fetchNewItems];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


@end
