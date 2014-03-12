//
//  STKProfileViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKProfileViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"
#import "STKProfileCell.h"
#import "STKCountView.h"
#import "STKUser.h"
#import "STKInitialProfileStatisticsCell.h"
#import "STKContentStore.h"
#import "STKTriImageCell.h"
#import "STKBaseStore.h"
#import "STKPostViewController.h"
#import "STKRequestItem.h"
#import "STKEditProfileViewController.h"
#import "UIERealTimeBlurView.h"
#import "STKHomeCell.h"
#import "STKFilterCell.h"
#import "STKCreatePostViewController.h"
#import "STKLocationViewController.h"
#import "STKImageSharer.h"

typedef enum {
    STKProfileSectionHeader,
    STKProfileSectionStatistics,
    STKProfileSectionPreinformation,
    STKProfileSectionInformation
} STKProfileSection;

@interface STKProfileViewController () <UITableViewDataSource, UITableViewDelegate, STKCountViewDelegate>

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) STKInitialProfileStatisticsCell *statsCell;


@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, getter = isShowingInformation) BOOL showingInformation;
@property (nonatomic) BOOL showPostsInSingleLayout;

- (BOOL)isShowingCurrentUserProfile;

@end

@implementation STKProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_user"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_user_selected"]];
        _posts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)imageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self showPostAtIndex:[ip row]];
}


- (BOOL)isShowingCurrentUserProfile
{
    return [[[self profile] userID] isEqualToString:[[[STKUserStore store] currentUser] userID]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self blurView] displayLink] setPaused:NO];
    
    if(![self profile]) {
        [self setProfile:[[STKUserStore store] currentUser]];
    }
    
    if([self isShowingCurrentUserProfile]) {
        [[self navigationItem] setTitle:@"Profile"];
        [[self navigationItem] setRightBarButtonItem:[self settingsBarButtonItem]];

    } else {
        [[self navigationItem] setTitle:@"Prism"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
    }
    
    [self refreshStatisticsView];
    if([self profile]) {
        [[STKUserStore store] fetchUserDetails:[self profile] completion:^(STKUser *u, NSError *err) {
            [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionHeader]
                            withRowAnimation:UITableViewRowAnimationNone];

            [self refreshStatisticsView];

            if(err) {
                NSLog(@"Display non-obtrusive error somewhere");
            }
        }];
        
        [[STKContentStore store] fetchProfilePostsForUser:[self profile]
                                              inDirection:STKContentStoreFetchDirectionNewer
                                            referencePost:[[self posts] firstObject]
                                               completion:^(NSArray *posts, NSError *err) {
                                                   if(!err) {
                                                       [[self posts] addObjectsFromArray:posts];
                                                       [[self posts] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
                                                       
                                                       
                                                       [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionInformation]
                                                                       withRowAnimation:UITableViewRowAnimationNone];
                                                       
                                                   } else {
                                                       // Do nothing?
                                                   }
                                               }];
    }
}

- (void)countView:(STKCountView *)countView didSelectCircleAtIndex:(int)index
{
    switch (index) {
        case 0: {
            
        } break;
        case 1: {
            
        } break;
        case 2: {
            [self scrollToPosts];
        } break;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];

    [self setStatsCell:[STKInitialProfileStatisticsCell cellForTableView:[self tableView] target:self]];
    //    [[self tableView] setDelaysContentTouches:NO];
}

- (void)scrollToPosts
{
    if([[self posts] count] > 0)
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:STKProfileSectionInformation]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:YES];
}

- (IBAction)showSinglePanePosts:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowPostsInSingleLayout:YES];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionInformation]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)showGridPosts:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowPostsInSingleLayout:NO];

    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionInformation]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)toggleFilterByUserPost:(id)sender atIndexPath:(NSIndexPath *)ip
{
}

- (IBAction)toggleFilterbyLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
}

- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [[self posts] objectAtIndex:[ip row]];
    if([[p creator] isEqual:[self profile]]) {
        return;
    }
    
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:[p creator]];
    [[self navigationController] pushViewController:vc animated:YES];

}

- (void)toggleLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *post = [[self posts] objectAtIndex:[ip row]];
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

- (void)showComments:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self showPostAtIndex:(int)[ip row]];
}


- (void)addToPrism:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKCreatePostViewController *pvc = [[STKCreatePostViewController alloc] init];
    [pvc setImageURLString:[[[self posts] objectAtIndex:[ip row]] imageURLString]];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
}

- (void)sharePost:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [[self posts] objectAtIndex:[ip row]];
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
    if([[[self posts] objectAtIndex:[ip row]] locationName]) {
        STKLocationViewController *lvc = [[STKLocationViewController alloc] init];
        [lvc setCoordinate:[[[self posts] objectAtIndex:[ip row]] coordinate]];
        [lvc setLocationName:[[[self posts] objectAtIndex:[ip row]] locationName]];
        [[self navigationController] pushViewController:lvc animated:YES];
    }
   
}

- (void)showPostAtIndex:(int)idx
{
    if(idx < [[self posts] count]) {
        STKPostViewController *vc = [[STKPostViewController alloc] init];
        [vc setPost:[[self posts] objectAtIndex:idx]];
        [[self navigationController] pushViewController:vc animated:YES];
    }
}

- (void)menuWillAppear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.5];
    [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.0];
    [[self navigationItem] setRightBarButtonItem:[self settingsBarButtonItem]];
}


- (void)leftImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSInteger row = [ip row];
    int itemIndex = (int)row * 3;
    [self showPostAtIndex:itemIndex];
}

- (void)centerImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSInteger row = [ip row];
    int itemIndex = (int)row * 3 + 1;
    [self showPostAtIndex:itemIndex];

}

- (void)rightImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSInteger row = [ip row];
    int itemIndex = (int)row * 3 + 2;
    [self showPostAtIndex:itemIndex];
}


- (void)editProfile:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKEditProfileViewController *ep = [[STKEditProfileViewController alloc] init];
    [[self navigationController] pushViewController:ep animated:YES];
}

- (void)toggleInformation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowingInformation:![self isShowingInformation]];
    [[self tableView] beginUpdates];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionPreinformation]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionInformation]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
}

- (void)requestTrust:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[STKUserStore store] createRequestOfType:STKRequestTypeTrust profile:[self profile] completion:^(id obj, NSError *err) {
        
    }];
}

- (void)follow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self profile] isFollowedByCurrentUser]) {
        [[STKUserStore store] unfollowUser:[self profile] completion:^(id obj, NSError *err) {
            [self refreshStatisticsView];
        }];
        
    } else {
        [[STKUserStore store] followUser:[self profile] completion:^(id obj, NSError *err) {
            [self refreshStatisticsView];
        }];
    }
    [self refreshStatisticsView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (void)populateProfileCell:(STKProfileCell *)c
{
    STKUser *p = [self profile];
    [[c nameLabel] setText:[p name]];
    if([p city] && [p state]) {
        NSString *city = [p city];
        NSString *state = [p state];
        [[c locationLabel] setText:[NSString stringWithFormat:@"%@, %@", city, state]];
    } else
        [[c locationLabel] setText:@""];
    
    [[c coverPhotoImageView] setUrlString:[p coverPhotoPath]];
    [[c avatarView] setUrlString:[p profilePhotoPath]];
}

- (void)refreshStatisticsView
{
    STKInitialProfileStatisticsCell *c = [self statsCell];
    if([self isShowingCurrentUserProfile]) {
        [[c followButton] setHidden:YES];
        [[c trustButton] setHidden:YES];
        [[c editButton] setHidden:NO];
    } else {
        [[c followButton] setHidden:NO];
        if([[self profile] isFollowedByCurrentUser]) {
            [[c followButton] setTitle:@"Unfollow" forState:UIControlStateNormal];
            [[c followButton] setImage:[UIImage imageNamed:@"following.png"]
                              forState:UIControlStateNormal];
            [[c followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
        } else {
            [[c followButton] setTitle:@"Follow" forState:UIControlStateNormal];
            [[c followButton] setImage:[UIImage imageNamed:@"btn_followarrow"]
                              forState:UIControlStateNormal];
            [[c followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        }
        [[c trustButton] setHidden:NO];
        [[c editButton] setHidden:YES];
    }
    
    [[c circleView] setCircleTitles:@[@"Followers", @"Following", @"Posts"]];

    
    NSString *followerCount = [NSString stringWithFormat:@"%d", [[self profile] followerCount]];
    NSString *followingCount = [NSString stringWithFormat:@"%d", [[self profile] followingCount]];
    NSString *postCount = [NSString stringWithFormat:@"%d", [[self profile] postCount]];
    if(!followerCount)
        followerCount = @"0";
    if(!followingCount)
        followingCount = @"0";
    if(!postCount)
        postCount = @"0";
 
    if(![self profile]) {
        followingCount = @"0";
        followerCount = @"0";
        postCount = @"0";
    }
    
    [[c circleView] setCircleValues:@[followerCount, followingCount, postCount]];
    
    [[c circleView] setDelegate:self];
}

- (void)populateTriImageCell:(STKTriImageCell *)c forRow:(int)row
{
    int arrayIndex = row * 3;
    
    if(arrayIndex + 0 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 0];
        [[c leftImageView] setUrlString:[p imageURLString]];
    } else {
        [[c leftImageView] setUrlString:nil];
    }
    if(arrayIndex + 1 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 1];
        [[c centerImageView] setUrlString:[p imageURLString]];
    } else {
        [[c centerImageView] setUrlString:nil];
    }
    
    if(arrayIndex + 2 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 2];
        [[c rightImageView] setUrlString:[p imageURLString]];
    } else {
        [[c rightImageView] setUrlString:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == STKProfileSectionHeader) {
        STKProfileCell *c = [STKProfileCell cellForTableView:tableView target:self];
        
        [self populateProfileCell:c];
        
        return c;
    } else if ([indexPath section] == STKProfileSectionStatistics) {
        return [self statsCell];
    } else if([indexPath section] == STKProfileSectionInformation) {
        if([self isShowingInformation]) {
            return nil;
        } else {
            if([self showPostsInSingleLayout]) {
                STKHomeCell *c = [STKHomeCell cellForTableView:tableView target:self];
                
                [c populateWithPost:[[self posts] objectAtIndex:[indexPath row]]];
                
                return c;
            } else {
                STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:self];
                [self populateTriImageCell:c forRow:[indexPath row]];
                
                return c;
            }
        }
    } else if ([indexPath section] == STKProfileSectionPreinformation) {
        if(![self isShowingInformation]) {
            STKFilterCell *c = [STKFilterCell cellForTableView:tableView target:self];
            return c;
        } else {
            UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
            return c;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == STKProfileSectionHeader) {
        return 246;
    } else if([indexPath section] == STKProfileSectionStatistics) {
        return 155;
    } else if ([indexPath section] == STKProfileSectionPreinformation) {
        return 50;
    } else if([indexPath section] == STKProfileSectionInformation) {
        if([self isShowingInformation]) {
            return 0;
        }
        if([self showPostsInSingleLayout]) {
            return 401;
        }
        return 106;
    }
    return 44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == STKProfileSectionHeader) {
        return 246;
    } else if([indexPath section] == STKProfileSectionStatistics) {
        return 155;
    } else if ([indexPath section] == STKProfileSectionPreinformation) {
        return 50;
    } else if([indexPath section] == STKProfileSectionInformation) {
        if([self isShowingInformation]) {
            return 0;
        }
        if([self showPostsInSingleLayout]) {
            return 401;
        }
        return 106;
    }
    return 44;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == STKProfileSectionInformation) {
        if(![self isShowingInformation]) {
            if([self showPostsInSingleLayout]) {
                return [[self posts] count];
            } else {
                if([[self posts] count] % 3 > 0)
                    return [[self posts] count] / 3 + 1;
                return [[self posts] count] / 3;
            }
        } else {
            return 0;
        }
    }
    
    return 1;
}

@end
