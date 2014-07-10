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
#import "STKCreateProfileViewController.h"
#import "UIERealTimeBlurView.h"
#import "STKPostCell.h"
#import "STKFilterCell.h"
#import "STKCreatePostViewController.h"
#import "STKLocationViewController.h"
#import "STKImageSharer.h"
#import "STKUserListViewController.h"
#import "STKUserPostListViewController.h"
#import "STKTrust.h"
#import "STKPostController.h"
#import "STKInstagramAuthViewController.h"
#import "STKNetworkStore.h"
#import "STKSettingsViewController.h"
#import "STKInstitutionInfoCell.h"
#import "STKWebViewController.h"
#import "STKFetchDescription.h"
#import "STKLuminatingBar.h"
#import "STKAccoladeViewController.h"

@import MessageUI;

typedef enum {
    STKProfileSectionStatic,
    STKProfileSectionPosts
} STKProfileSection;

@interface STKProfileViewController ()
    <UITableViewDataSource, UITableViewDelegate, STKCountViewDelegate, STKPostControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet STKLuminatingBar *luminatingBar;

@property (nonatomic, strong) STKProfileCell *profileView;
@property (nonatomic, strong) STKInitialProfileStatisticsCell *statsView;
@property (nonatomic, strong) STKFilterCell *filterView;

@property (nonatomic, strong) NSArray *luminaries;
@property (nonatomic, strong) STKPostController *postController;
@property (nonatomic, strong) STKPostController *tagsPostController;

@property (nonatomic) BOOL showPostsInSingleLayout;
@property (nonatomic) BOOL filterByLocation;
@property (nonatomic) BOOL filterByUserTags;

- (BOOL)isShowingCurrentUserProfile;

@end

@implementation STKProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        [[self tabBarItem] setTitle:@"Profile"];
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_user"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_user_selected"]];
        [self setFilterByUserTags:NO];
        _postController = [[STKPostController alloc] initWithViewController:self];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)showSettings:(id)sender
{
    STKSettingsViewController *svc = [[STKSettingsViewController alloc] initWithItems:nil];
    [[self navigationController] pushViewController:svc animated:YES];
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
    
    if ([[self profile] active] == NO) {
        [[self tableView] setHidden:YES];
        [[self navigationItem] setTitle:@"Prizm"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [self refreshProfileViews];
        
        return;
    }
    
    
    if([self isShowingCurrentUserProfile]) {
        [[self navigationItem] setTitle:@"Me"];
        [[self navigationItem] setRightBarButtonItem:[self settingsBarButtonItem]];

    } else {
        [[self navigationItem] setTitle:@"Prizm"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
    }
    
    if([[[self navigationController] viewControllers] indexOfObject:self] > 0) {
        [[self navigationItem] setLeftBarButtonItem:[self backButtonItem]];
    }
    
    
    if([self profile]) {
        NSArray *additionalFields = nil;
        if([[self profile] isInstitution]) {
            additionalFields = @[@"enrollment", @"date_founded", @"mascot", @"email"];
        }

        __weak id ws = self;
        [[self postController] setFetchMechanism:^(STKFetchDescription *fs, void (^completion)(NSArray *posts, NSError *err)) {
            [[STKContentStore store] fetchProfilePostsForUser:[ws profile] fetchDescription:fs completion:completion];
        }];
        
        [[STKUserStore store] fetchUserDetails:[self profile] additionalFields:additionalFields completion:^(STKUser *u, NSError *err) {
            if(!err) {
                if([[self profile] isInstitution]) {
                    STKFetchDescription *fd = [[STKFetchDescription alloc] init];
                    [fd setFilterDictionary:@{@"status" : STKRequestStatusAccepted}];
                    [[STKUserStore store] fetchTrustsForUser:[self profile] fetchDescription:fd completion:^(NSArray *trusts, NSError *err) {
                        [self determineLuminariesFromTrusts:trusts];
                        [[STKUserStore store] fetchTrustForUser:[self profile] otherUser:[[STKUserStore store] currentUser]
                                                     completion:^(STKTrust *t, NSError *err) {
                                                         [self fetchNewPosts];
                                                         [self refreshProfileViews];
                                                     }];
                    }];
                } else {
                    if(![[self profile] isEqual:[[STKUserStore store] currentUser]]) {
                        [[STKUserStore store] fetchTrustForUser:[self profile] otherUser:[[STKUserStore store] currentUser]
                                                     completion:^(STKTrust *t, NSError *err) {
                                                         [self fetchNewPosts];
                                                         [self refreshProfileViews];
                                                     }];
                    } else {
                        [self fetchNewPosts];
                    }
                }
            }
            
            [self refreshProfileViews];
        }];
    }

    [self refreshProfileViews];
}

- (void)determineLuminariesFromTrusts:(NSArray *)trusts
{
    NSMutableArray *lums = [NSMutableArray array];
    for(STKTrust *t in [[self profile] ownedTrusts]) {
        if ([t.status isEqualToString:STKRequestStatusAccepted]) {
            [lums addObject:[t recepient]];
        }
    }
    for(STKTrust *t in [[self profile] receivedTrusts]) {
        if ([t.status isEqualToString:STKRequestStatusAccepted]) {
            [lums addObject:[t creator]];
        }
    }
    [self setLuminaries:lums];
}

- (void)showMoreLuminariesTapped:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    STKUserListViewController *vc = [[STKUserListViewController alloc] init];
    [vc setUsers:[self luminaries]];
    [vc setTitle:@"Luminary"];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)websiteTapped:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = [[self profile] website];
    if([urlString rangeOfString:@"http"].location == NSNotFound) {
        urlString = [@"http://" stringByAppendingString:urlString];
    }
    STKWebViewController *wvc = [[STKWebViewController alloc] init];
    [wvc setUrl:[NSURL URLWithString:urlString]];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)countView:(STKCountView *)countView didSelectCircleAtIndex:(int)index
{
    NSPredicate *activeUsersOnly = [NSPredicate predicateWithFormat:@"(active == YES)"];
    
    switch (index) {
        case 0: {
            STKUserListViewController *vc = [[STKUserListViewController alloc] init];
            [vc setTitle:@"Followers"];
            [[self navigationController] pushViewController:vc animated:YES];
            [[STKUserStore store] fetchFollowersOfUser:[self profile] completion:^(NSArray *followers, NSError *err) {
                [vc setUsers:[followers filteredArrayUsingPredicate:activeUsersOnly]];
            }];
        } break;
        case 1: {
            STKUserListViewController *vc = [[STKUserListViewController alloc] init];
            [vc setTitle:@"Following"];
            [[self navigationController] pushViewController:vc animated:YES];
            [[STKUserStore store] fetchUsersFollowingOfUser:[self profile] completion:^(NSArray *followers, NSError *err) {
                [vc setUsers:[followers filteredArrayUsingPredicate:activeUsersOnly]];
            }];
        } break;
        case 2: {
            STKUserPostListViewController *pvc = [[STKUserPostListViewController alloc] initWithUser:[self profile]];
            [pvc setTitle:[[self profile] name]];
            [[self navigationController] pushViewController:pvc animated:YES];
        } break;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];

    [self setStatsView:[STKInitialProfileStatisticsCell cellForTableView:[self tableView] target:self]];
    [self setProfileView:[STKProfileCell cellForTableView:[self tableView] target:self]];
    [self setFilterView:[STKFilterCell cellForTableView:[self tableView] target:self]];
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [[[self filterView] gridViewButton] setSelected:YES];
}


- (IBAction)showSinglePanePosts:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowPostsInSingleLayout:YES];
    [[[self filterView] gridViewButton] setSelected:NO];
    [[[self filterView] singleViewButton] setSelected:YES];
    [[self tableView] reloadData];
}

- (IBAction)showGridPosts:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowPostsInSingleLayout:NO];
    [[[self filterView] gridViewButton] setSelected:YES];
    [[[self filterView] singleViewButton] setSelected:NO];
    [[self tableView] reloadData];
}

- (NSDictionary *)filterDictionary
{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if([self filterByLocation]) {
        [d setObject:STKQueryObjectFilterExists forKey:@"locationName"];
    }
    if([self filterByUserTags]) {
        [d setObject:[[self profile] uniqueID] forKey:@"tags.uniqueID"];
    }
    
    if(![self isShowingCurrentUserProfile]) {
        if([[self profile] trustForUser:[[STKUserStore store] currentUser]]) {
            [d setObject:@"trust public" forKey:@"visibility"];
        } else {
            [d setObject:@"public" forKey:@"visibility"];
        }
    } else {
        [d setObject:@"private trust public" forKey:@"visibility"];
    }
    
    return d;
}

- (IBAction)toggleFilterByUserPost:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setFilterByUserTags:![self filterByUserTags]];
    [self setFilterByLocation:NO];
    [[[self filterView] locationButton] setSelected:NO];
    [[[self filterView] userButton] setSelected:[self filterByUserTags]];
    [[self postController] setFilterMap:[self filterDictionary]];
    [[self postController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
    
    [[self tableView] reloadData];
    
}

- (IBAction)toggleFilterbyLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setFilterByLocation:![self filterByLocation]];
    [self setFilterByUserTags:NO];
    [[self filterView] setSelected:NO];
    [[[self filterView] locationButton] setSelected:[self filterByLocation]];
    [[[self filterView] userButton] setSelected:[self filterByUserTags]];

    [[self postController] setFilterMap:[self filterDictionary]];
    [[self postController] reloadWithCompletion:^(NSArray *newPosts, NSError *err) {
        [[self tableView] reloadData];
    }];
    [[self tableView] reloadData];
}

- (void)fetchNewPosts
{
    if([[self profile] postCount] > 0){
        [[self luminatingBar] setLuminating:YES];
        [[self postController] setFilterMap:[self filterDictionary]];
        [[self postController] fetchNewerPostsWithCompletion:^(NSArray *newPosts, NSError *err) {
            [[self luminatingBar] setLuminating:NO];
            [[self tableView] reloadData];
        }];
    }
}

- (void)fetchOlderPosts
{
    if([[self  profile] postCount] > 0){
        [[self postController] setFilterMap:[self filterDictionary]];
        [[self postController] fetchOlderPostsWithCompletion:^(NSArray *newPosts, NSError *err) {
            [[self tableView] reloadData];
        }];
    }
}


- (BOOL)postController:(STKPostController *)pc shouldContinueAfterTappingAvatarAtIndex:(int)idx
{
    STKPost *p = [[[self postController] posts] objectAtIndex:idx];
    if([[p creator] isEqual:[self profile]]) {
        return NO;
    }
    return YES;
}

- (UITableViewCell *)postController:(STKPostController *)pc cellForPostAtIndexPath:(NSIndexPath *)ip
{
    return [[self tableView] cellForRowAtIndexPath:ip];
}


- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx
{
    if([self showPostsInSingleLayout]) {
        STKPostCell *c = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:STKProfileSectionPosts]];
        
        return [[self view] convertRect:[[c contentImageView] frame] fromView:[[c contentImageView] superview]];
    } else {
        int row = idx / 3;
        int offset = idx % 3;
        
        STKTriImageCell *c = (STKTriImageCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:STKProfileSectionPosts]];
        
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
    [[self navigationItem] setRightBarButtonItem:nil];
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

- (void)sendMessage:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self profile] email]) {
        MFMailComposeViewController *mvc = [[MFMailComposeViewController alloc] init];
        [mvc setMailComposeDelegate:self];
        [mvc setToRecipients:@[[[self profile] email]]];
        [mvc setSubject:@"Prizm: Contact Us"];
        [self presentViewController:mvc animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showUser:(STKUser *)u
{
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:u];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)leftLuminaryTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self luminaries] count] > 0) {
        [self showUser:[[self luminaries] objectAtIndex:0]];
    }
}

- (void)centerLuminaryTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self luminaries] count] > 1) {
        [self showUser:[[self luminaries] objectAtIndex:1]];
    }
}

- (void)rightLuminaryTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self luminaries] count] > 2) {
        [self showUser:[[self luminaries] objectAtIndex:2]];
    }
}

- (void)requestTrust:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKTrust *t = [[self profile] trustForUser:[[STKUserStore store] currentUser]];

    if(!t || [t isCancelled]) {
        [[STKUserStore store] requestTrustForUser:[self profile] completion:^(STKTrust *requestItem, NSError *err) {
            [self refreshProfileViews];
        }];
    } else if([t isPending]) {
        if([[t recepient] isEqual:[[STKUserStore store] currentUser]]) {
            // Accept
            [[STKUserStore store] acceptTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                [self refreshProfileViews];
            }];
        } else {
            [[STKUserStore store] cancelTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                [self refreshProfileViews];
            }];
        }
    } else if([t isRejected]) {
        if([[t recepient] isEqual:[[STKUserStore store] currentUser]]) {
            // Do nothing, is rejected
        } else {
            [[STKUserStore store] cancelTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                [self refreshProfileViews];
            }];
        }
    } else if([t isAccepted]) {
        // do nothing!
    }
    [self refreshProfileViews];
}

- (void)showAccolades:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKAccoladeViewController *avc = [[STKAccoladeViewController alloc] init];
    [avc setUser:[self profile]];
    [[self navigationController] pushViewController:avc animated:YES];
}

- (void)follow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self profile] isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[STKUserStore store] unfollowUser:[self profile] completion:^(id obj, NSError *err) {
            [self refreshProfileViews];
        }];
        
    } else {
        [[STKUserStore store] followUser:[self profile] completion:^(id obj, NSError *err) {
            [self refreshProfileViews];
        }];
    }
    [self refreshProfileViews];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)setLuminaries:(NSArray *)luminaries
{
    _luminaries = luminaries;
    
    [[self profileView] setLuminaries:luminaries];
}

- (void)refreshProfileViews
{
    STKUser *p = [self profile];
    
    if ([p isInstitution] && ![p isLuminary]) {
        [[self profileView] setType:STKProfileCellTypeInstitution];
        NSDate *founded;
        NSString *mascot, *pop;
        founded = [p dateFounded];
        mascot = [p mascotName];
        pop = [p enrollment];
        
        NSMutableArray *infoComponents = [NSMutableArray array];
        if (founded != nil) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];

            [infoComponents addObject:[NSString stringWithFormat:@"Founded %@", [dateFormatter stringFromDate:founded]]];
        }
        if (mascot != nil) {
            [infoComponents addObject:[NSString stringWithFormat:@"Mascot %@", mascot]];
        }
        if (pop != nil) {
            [infoComponents addObject:[NSString stringWithFormat:@"Pop %@", pop]];
        }
        
        [[[self profileView] luminaryInfoLabel] setText:[infoComponents componentsJoinedByString:@" • "]];
        [[self profileView] setLuminaries:[self luminaries]];
        
    } else {
        [[self profileView] setType:STKProfileCellTypeUser];
    }
    [[[self profileView] blurbLabel] setText:[p blurb]];
    
    
    [[[self profileView] luminaryIcon] setHidden:![p isLuminary]];
    
    if ([p website]) {
        NSAttributedString *attributedWebsite = [[NSAttributedString alloc] initWithString:[p website] attributes:@{NSFontAttributeName : STKFont(12), NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [[[self profileView] websiteButton] setAttributedTitle:attributedWebsite forState:UIControlStateNormal];
    }
    [[[self profileView] nameLabel] setText:[p name]];
    if([p city] && [p state]) {
        NSString *city = [p city];
        NSString *state = [p state];
        [[[self profileView] locationLabel] setText:[NSString stringWithFormat:@"%@, %@", city, state]];
    } else
        [[[self profileView] locationLabel] setText:@""];
    
    if ([p coverPhotoPath]) {
        [[[self profileView] coverPhotoImageView] setUrlString:[p coverPhotoPath]];
    } else {
        UIImage *defaultImage = [UIImage imageNamed:@"coverphotoholder"];
        [[[self profileView] coverPhotoImageView] setImage:defaultImage];
    }
    [[[self profileView] avatarView] setUrlString:[p profilePhotoPath]];
    
    
    STKInitialProfileStatisticsCell *c = [self statsView];
    if([self isShowingCurrentUserProfile]) {
        [[c accoladesButton] setHidden:YES]; //force hide accolades button for v1
        [[c followButton] setHidden:YES];
        [[c trustButton] setHidden:YES];
        [[c editButton] setHidden:NO];
        [[c messageButton] setHidden:YES];
        
        if([[self profile] isInstitution]) {
            [[c accoladesButton] setHidden:YES];
        }
    } else {
        
        [[c editButton] setHidden:YES];
        
        STKUser *currentUser = [[STKUserStore store] currentUser];
        BOOL currentUserToRequestPrivs = [currentUser isInstitution] || [currentUser isLuminary];
        BOOL showingUserHasRestrictedPrivs = [[self profile] isInstitution] || [[self profile] isLuminary];
        
        if(showingUserHasRestrictedPrivs && !currentUserToRequestPrivs) {
            [[c trustButton] setHidden:YES];
            [[c messageButton] setHidden:![MFMailComposeViewController canSendMail]];
        } else {
            [[c trustButton] setHidden:NO];
            [[c messageButton] setHidden:YES];
        }

        STKTrust *t = [[self profile] trustForUser:[[STKUserStore store] currentUser]];

        if([t isAccepted]) {
            [[c followButton] setHidden:YES];
            [[c accoladesButton] setHidden:YES]; //force hide accolades button for v1
            
        } else {
            [[c followButton] setHidden:NO];
            [[c accoladesButton] setHidden:YES];
            
            
            if([[self profile] isFollowedByUser:[[STKUserStore store] currentUser]]) {
                [[c followButton] setTitle:@"Following" forState:UIControlStateNormal];
                [[c followButton] setImage:[UIImage imageNamed:@"following.png"]
                                  forState:UIControlStateNormal];
                [[c followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 66, 0, 0)];
            } else {
                [[c followButton] setTitle:@"Follow" forState:UIControlStateNormal];
                [[c followButton] setImage:[UIImage imageNamed:@"arrowblue.png"]
                                  forState:UIControlStateNormal];
                [[c followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
            }
        }
    
        if(!t || [t isCancelled]) {
            if([[[STKUserStore store] currentUser] isInstitution]) {
                [[c trustButton] setTitle:@"Request Luminary" forState:UIControlStateNormal];
                [[c trustButton] setTitleEdgeInsets:UIEdgeInsetsMake(0, -90, 0, 0)];
            } else {
                [[c trustButton] setTitle:@"Request Trust" forState:UIControlStateNormal];
                [[c trustButton] setTitleEdgeInsets:UIEdgeInsetsMake(0, -60, 0, 0)];
            }
            [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
            
            [[c trustButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 95, 0, 0)];
        } else {
            if([t isPending]) {
                if([[t recepient] isEqual:[[STKUserStore store] currentUser]]) {
                    [[c trustButton] setTitle:@"Accept" forState:UIControlStateNormal];
                    [[c trustButton] setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
                    [[c trustButton] setImage:[UIImage imageNamed:@"activity_accept_trust"] forState:UIControlStateNormal];
                } else {
                    [[c trustButton] setTitle:@"Requested" forState:UIControlStateNormal];
                    [[c trustButton] setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
                    [[c trustButton] setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
                }
            } else if([t isRejected]) {
                if([[t recepient] isEqual:[[STKUserStore store] currentUser]]) {
                    [[c trustButton] setTitle:@"Request Trust" forState:UIControlStateNormal];
                    [[c trustButton] setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
                    [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
                } else {
                    [[c trustButton] setTitle:@"Requested" forState:UIControlStateNormal];
                    [[c trustButton] setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
                    [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
                }
            } else if([t isAccepted]) {
                [[c trustButton] setTitle:@"Trusted" forState:UIControlStateNormal];
                [[c trustButton] setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
                [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
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
    if([indexPath section] == STKProfileSectionStatic) {
        if([indexPath row] == 0) {
            return [self profileView];
        } else if([indexPath row] == 1) {
            return [self statsView];
        } else if([indexPath row] == 2) {
            return [self filterView];
        }
    } else if([indexPath section] == STKProfileSectionPosts) {
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
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == STKProfileSectionStatic) {
        if([indexPath row] == 0)
            return 182;
        if([indexPath row] == 1)
            return 155;
        if([indexPath row] == 2) {
            return 50;
        }
    } else if([indexPath section] == STKProfileSectionPosts) {
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
    CGRect r = [[[self profile] blurb] boundingRectWithSize:CGSizeMake(300, 10000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : f} context:nil];

    return r.size.height + 8;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == STKProfileSectionPosts) {
        int count = [[[self postController] posts] count];
        if([self showPostsInSingleLayout]) {
            return count;
        } else {
            if(count % 3 > 0)
                return count / 3 + 1;
            return count / 3;
        }
    }
    return 3;
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
