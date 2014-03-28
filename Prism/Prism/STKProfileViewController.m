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
#import "STKCreateProfileViewController.h"
#import "UIERealTimeBlurView.h"
#import "STKPostCell.h"
#import "STKFilterCell.h"
#import "STKCreatePostViewController.h"
#import "STKLocationViewController.h"
#import "STKImageSharer.h"
#import "STKUserListViewController.h"
#import "STKUserPostListViewController.h"
#import "STKProfileInformationCell.h"
#import "STKTrust.h"
#import "STKPostController.h"

typedef enum {
    STKProfileSectionHeader,
    STKProfileSectionStatistics,
    STKProfileSectionPreinformation,
    STKProfileSectionInformation
} STKProfileSection;

@interface STKProfileViewController () <UITableViewDataSource, UITableViewDelegate, STKCountViewDelegate, STKPostControllerDelegate>

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) STKInitialProfileStatisticsCell *statsCell;

@property (nonatomic, strong) STKPostController *postController;

@property (nonatomic, getter = isShowingInformation) BOOL showingInformation;
@property (nonatomic) BOOL showPostsInSingleLayout;
@property (nonatomic) BOOL filterByLocation;

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
        _postController = [[STKPostController alloc] initWithViewController:self];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (BOOL)isShowingCurrentUserProfile
{
    return [[[self profile] uniqueID] isEqualToString:[[[STKUserStore store] currentUser] uniqueID]];
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
                                            referencePost:[[[self postController] posts] firstObject]
                                               completion:^(NSArray *posts, NSError *err) {
                                                   if(!err) {
                                                       [[self postController] addPosts:posts];
                                                       
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
            STKUserListViewController *vc = [[STKUserListViewController alloc] init];
            [vc setTitle:@"Followers"];
            [[self navigationController] pushViewController:vc animated:YES];
            [[STKUserStore store] fetchFollowersOfUser:[self profile] completion:^(NSArray *followers, NSError *err) {
                [vc setUsers:followers];
            }];
        } break;
        case 1: {
            STKUserListViewController *vc = [[STKUserListViewController alloc] init];
            [vc setTitle:@"Following"];
            [[self navigationController] pushViewController:vc animated:YES];
            [[STKUserStore store] fetchUsersFollowingOfUser:[self profile] completion:^(NSArray *followers, NSError *err) {
                [vc setUsers:followers];
            }];
        } break;
        case 2: {
            STKUserPostListViewController *pvc = [[STKUserPostListViewController alloc] init];
            [pvc setTitle:[[self profile] name]];
            [pvc setPosts:[[self postController] posts]];
            [[self navigationController] pushViewController:pvc animated:YES];
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
    if([[[self postController] posts] count] > 0)
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:STKProfileSectionInformation]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:YES];
}

- (IBAction)showSinglePanePosts:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowPostsInSingleLayout:YES];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionInformation]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionPreinformation]
                    withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)showGridPosts:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowPostsInSingleLayout:NO];

    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionInformation]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionPreinformation]
                    withRowAnimation:UITableViewRowAnimationNone];

}

- (IBAction)toggleFilterByUserPost:(id)sender atIndexPath:(NSIndexPath *)ip
{
}

- (IBAction)toggleFilterbyLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setFilterByLocation:![self filterByLocation]];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionInformation]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionPreinformation]
                    withRowAnimation:UITableViewRowAnimationNone];
}


- (BOOL)postController:(STKPostController *)pc shouldContinueAfterTappingAvatarAtIndex:(int)idx
{
    STKPost *p = [[[self postController] posts] objectAtIndex:idx];
    if([[p creator] isEqual:[self profile]]) {
        return NO;
    }
    return YES;
}

- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx
{
    if([self showPostsInSingleLayout]) {
        STKPostCell *c = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:STKProfileSectionInformation]];
        
        return [[self view] convertRect:[[c contentImageView] frame] fromView:[[c contentImageView] superview]];
    } else {
        int row = idx / 3;
        int offset = idx % 3;
        
        STKTriImageCell *c = (STKTriImageCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:STKProfileSectionInformation]];
        
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

- (void)editProfile:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKCreateProfileViewController *ep = [[STKCreateProfileViewController alloc] initWithProfileForEditing:[self profile]];
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
    STKTrust *t = [[self profile] trustForUser:[[STKUserStore store] currentUser]];

    if(!t || [t isCancelled]) {
        [[STKUserStore store] requestTrustForUser:[self profile] completion:^(STKTrust *requestItem, NSError *err) {
            [self refreshStatisticsView];
        }];
    } else if([t isPending]) {
        if([[t requestor] isEqual:[self profile]]) {
            // Accept
            [[STKUserStore store] acceptTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                [self refreshStatisticsView];
            }];
        } else {
            [[STKUserStore store] cancelTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                [self refreshStatisticsView];
            }];
        }
    } else if([t isRejected]) {
        if([[t requestor] isEqual:[self profile]]) {
            // Do nothing, is rejected
        } else {
            [[STKUserStore store] cancelTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                [self refreshStatisticsView];
            }];
        }
    } else if([t isAccepted]) {
        [[STKUserStore store] rejectTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
            [self refreshStatisticsView];
        }];
    }
    [self refreshStatisticsView];
}

- (void)showAccolades:(id)sender atIndexPath:(NSIndexPath *)ip
{
    
}

- (void)follow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self profile] isFollowedByUser:[[STKUserStore store] currentUser]]) {
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
    
    [c setShowPrismImageForToggleButton:[self isShowingInformation]];
}

- (void)refreshStatisticsView
{
    STKInitialProfileStatisticsCell *c = [self statsCell];
    if([self isShowingCurrentUserProfile]) {
        [[c accoladesButton] setHidden:NO];
        [[c followButton] setHidden:YES];
        [[c trustButton] setHidden:YES];
        [[c editButton] setHidden:NO];
    } else {
        [[c accoladesButton] setHidden:YES];
        [[c followButton] setHidden:NO];
        if([[self profile] isFollowedByUser:[[STKUserStore store] currentUser]]) {
            [[c followButton] setTitle:@"Following" forState:UIControlStateNormal];
            [[c followButton] setImage:[UIImage imageNamed:@"reject"]
                              forState:UIControlStateNormal];
            [[c followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 66, 0, 0)];
        } else {
            [[c followButton] setTitle:@"Follow" forState:UIControlStateNormal];
            [[c followButton] setImage:[UIImage imageNamed:@"following.png"]
                              forState:UIControlStateNormal];
            [[c followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        }
        [[c trustButton] setHidden:NO];
        [[c editButton] setHidden:YES];
    
        STKTrust *t = [[self profile] trustForUser:[[STKUserStore store] currentUser]];
        if(!t || [t isCancelled]) {
            [[c trustButton] setTitle:@"Request Trust" forState:UIControlStateNormal];
            [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
            [[c trustButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 95, 0, 0)];
        } else {
            if([t isPending]) {
                if([[t requestor] isEqual:[self profile]]) {
                    [[c trustButton] setTitle:@"Accept" forState:UIControlStateNormal];
                    [[c trustButton] setImage:[UIImage imageNamed:@"activity_accept_trust"] forState:UIControlStateNormal];
                } else {
                    [[c trustButton] setTitle:@"Pending" forState:UIControlStateNormal];
                    [[c trustButton] setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
                }
            } else if([t isRejected]) {
                if([[t requestor] isEqual:[self profile]]) {
                    [[c trustButton] setTitle:@"Rejected" forState:UIControlStateNormal];
                    [[c trustButton] setImage:nil forState:UIControlStateNormal];
                } else {
                    [[c trustButton] setTitle:@"Pending" forState:UIControlStateNormal];
                    [[c trustButton] setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
                }
            } else if([t isAccepted]) {
                [[c trustButton] setTitle:@"Trusted" forState:UIControlStateNormal];
                [[c trustButton] setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
            }
        }
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
            STKProfileInformationCell *c = [STKProfileInformationCell cellForTableView:tableView target:self];
            [[c infoLabel] setText:[[self profile] blurb]];
            return c;
        } else {
            if([self showPostsInSingleLayout]) {
                STKPostCell *c = [STKPostCell cellForTableView:tableView target:[self postController]];
                
                [c populateWithPost:[[[self postController] posts] objectAtIndex:[indexPath row]]];
                
                return c;
            } else {
                STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self postController]];
                [c populateWithPosts:[[self postController] posts] indexOffset:[indexPath row] * 3];
                
                return c;
            }
        }
    } else if ([indexPath section] == STKProfileSectionPreinformation) {
        if(![self isShowingInformation]) {
            STKFilterCell *c = [STKFilterCell cellForTableView:tableView target:self];
            [[c gridViewButton] setSelected:![self showPostsInSingleLayout]];
            [[c singleViewButton] setSelected:[self showPostsInSingleLayout]];
            [[c locationButton] setSelected:[self filterByLocation]];

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
            return [self heightForInfoCell];
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
            return [self heightForInfoCell];
        }
        if([self showPostsInSingleLayout]) {
            return 401;
        }
        return 106;
    }
    return 44;
}

- (CGFloat)heightForInfoCell
{
    static UIFont *f = nil;
    if(!f) {
        f = STKFont(14);
    }
    CGRect r = [[[self profile] blurb] boundingRectWithSize:CGSizeMake(200, 10000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : f} context:nil];

    return r.size.height + 60;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == STKProfileSectionInformation) {
        if(![self isShowingInformation]) {
            int count = [[[self postController] posts] count];
            if([self showPostsInSingleLayout]) {
                return count;
            } else {
                if(count % 3 > 0)
                    return count / 3 + 1;
                return count / 3;
            }
        } else {
            return 1;
        }
    } else if(section == STKProfileSectionPreinformation) {
        if([self isShowingInformation])
            return 0;
        return 1;
    }
    
    return 1;
}

@end
