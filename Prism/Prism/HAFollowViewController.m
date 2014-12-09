//
//  HAFollowViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAFollowViewController.h"
#import "STKContentStore.h"
#import "STKUserStore.h"
#import "HAFollowCell.h"
#import "STKFetchDescription.h"
#import "UIERealTimeBlurView.h"
#import "STKPostViewController.h"
#import "STKLocationViewController.h"
#import "STKProfileViewController.h"
#import "UIViewController+STKControllerItems.h"

@interface HAFollowViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSMutableArray *posts;

@end

@implementation HAFollowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{

//    [[self blurView] setAlpha:0.0f];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];
    if ([self isStandalone]) {
        [self.navigationController.navigationBar setTintColor:[UIColor HATextColor]];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
        
        [self.navigationItem setRightBarButtonItem:done];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Who to Follow";
    [self.navigationController setNavigationBarHidden:NO];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage HABackgroundImage]]];
    UIView *blankView = [[UIView alloc] init];
    [blankView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setContentInset:UIEdgeInsetsMake(3, 0, 0, 0)];
    [self addBlurViewWithHeight:64.f];
    
    id sort = ^(STKUser *user1, STKUser *user2){
        NSNumber *count1 = @(user1.matchingInterestsCount);
        NSNumber *count2 = @(user2.matchingInterestsCount);
        return [count2 compare:count1];
    };
    [[STKUserStore store] searchUsersWithType:@"luminary" completion:^(NSArray *profiles, NSError *err) {
        NSPredicate *notFollowing = [NSPredicate predicateWithBlock:^BOOL(STKUser *user, NSDictionary *bindings) {
            return (![user isFollowedByUser:[[STKUserStore store] currentUser]]) && user.postCount > 2;
        }];
        NSArray *filtered = [profiles filteredArrayUsingPredicate:notFollowing];
        self.users = [filtered sortedArrayUsingComparator:sort];
        STKFetchDescription *desc = [[STKFetchDescription alloc] init];
        desc.limit = 3;
        self.posts = [NSMutableArray arrayWithArray:self.users];
        [self.tableView reloadData];
        [self.users enumerateObjectsUsingBlock:^(STKUser *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@: %ld", [obj name], (long)[obj matchingInterestsCount]);
        }];
        [self.users enumerateObjectsUsingBlock:^(STKUser *obj, NSUInteger idx, BOOL *stop) {
           [[STKContentStore store] fetchProfilePostsForUser:obj fetchDescription:desc completion:^(NSArray *posts, NSError *err) {
               if (posts && posts.count > 0) {
                   [self.posts replaceObjectAtIndex:idx withObject:posts];
               } else {
                   [self.posts replaceObjectAtIndex:idx withObject:posts];
               }
               if (obj == [self.users lastObject]){
                   [self.tableView reloadData];
               }
           }];
        }];
    }];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAFollowCell *cell = [HAFollowCell cellForTableView:tableView target:self];
    [cell setProfile:[self.users objectAtIndex:indexPath.row]];
    if (self.posts.count > indexPath.row) {
        [cell setPosts:[self.posts objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 255.0;
}

#pragma mark Method Handlers
- (void)followTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    HAFollowCell *selectedCell = (HAFollowCell *)[self.tableView cellForRowAtIndexPath:ip];
    STKUser *profile = [selectedCell profile];
    if([profile isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[STKUserStore store] unfollowUser:profile completion:^(id obj, NSError *err) {
            if (err) {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
            [selectedCell setFollowed];
//            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
    } else {
        [[STKUserStore store] followUser:profile completion:^(id obj, NSError *err) {
            if (err) {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
            [selectedCell setFollowed];
//            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
}

- (void)leftPostTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self presentPostFromCell:(HAFollowCell *)[self.tableView cellForRowAtIndexPath:ip] index:0];
}

- (void)centerPostTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self presentPostFromCell:(HAFollowCell *)[self.tableView cellForRowAtIndexPath:ip] index:1];
}

- (void)rightPostTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self presentPostFromCell:(HAFollowCell *)[self.tableView cellForRowAtIndexPath:ip] index:2];
}

- (void)presentPostFromCell:(HAFollowCell *)cell index:(int)idx
{
    STKPost *post = [cell.posts objectAtIndex:idx];
    STKResolvingImageView *iv = nil;
    switch (idx) {
        case 0:
            iv = cell.leftImage;
            break;
        case 1:
            iv = cell.centerImage;
            break;
        case 2:
            iv = cell.rightImage;
            break;
            
        default:
            iv = [[STKResolvingImageView alloc] init];
            break;
    }
    
    
    [[self menuController] transitionToPost:post
                                   fromRect:[[self view] convertRect:[iv frame] fromView:cell]
                                 usingImage:[iv image]
                           inViewController:self
                                   animated:YES];
}

- (STKMenuController *)menuController
{
    UIViewController *parent = [self parentViewController];
    while(parent != nil) {
        if([parent isKindOfClass:[STKMenuController class]])
            return (STKMenuController *)parent;
        
        parent = [parent parentViewController];
    }
    return nil;
}


- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *user = [[self users] objectAtIndex:ip.row];
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:user];
    [[self navigationController] pushViewController:vc animated:YES];
}


@end
