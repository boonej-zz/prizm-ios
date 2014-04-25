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
#import "STKLuminariesCell.h"
#import "STKInstagramAuthViewController.h"
#import "STKNetworkStore.h"
#import "STKSettingsViewController.h"
#import "STKInstitutionInfoCell.h"

@import MessageUI;

typedef enum {
    STKProfileSectionStatic,
    STKProfileSectionDynamic
} STKProfileSection;

@interface STKProfileViewController ()
    <UITableViewDataSource, UITableViewDelegate, STKCountViewDelegate, STKPostControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) STKProfileCell *profileView;
@property (nonatomic, strong) STKInitialProfileStatisticsCell *statsView;
@property (nonatomic, strong) STKFilterCell *filterView;

@property (nonatomic, strong) NSArray *luminaries;
@property (nonatomic, strong) STKPostController *postController;

@property (nonatomic, getter = isShowingLuminaries) BOOL showingLuminaries;
@property (nonatomic, getter = isShowingInformation) BOOL showingInformation;
@property (nonatomic) BOOL showPostsInSingleLayout;
@property (nonatomic) BOOL filterByLocation;

@property (nonatomic, strong) UIButton *luminaryButton;

- (BOOL)isShowingCurrentUserProfile;

@end

@implementation STKProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self tabBarItem] setTitle:@"Profile"];
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
    
    if([self isShowingCurrentUserProfile]) {
        [[self navigationItem] setTitle:@"Profile"];
        [[self navigationItem] setRightBarButtonItem:[self settingsBarButtonItem]];

    } else {
        [[self navigationItem] setTitle:@"Prizm"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
    }
    
    if([[[self navigationController] viewControllers] indexOfObject:self] > 0) {
        [[self navigationItem] setLeftBarButtonItem:[self backButtonItem]];
    }
    
    [self refreshProfileViews];
    if([self profile]) {
        if([[[self profile] type] isEqualToString:STKUserTypeInstitution]) {

        }
        
        NSArray *additionalFields = nil;
        if([[[self profile] type] isEqualToString:STKUserTypeInstitution]) {
            additionalFields = @[@"enrollment", @"date_founded", @"mascot", @"email"];
        }
        [[STKUserStore store] fetchUserDetails:[self profile] additionalFields:additionalFields completion:^(STKUser *u, NSError *err) {
            [self refreshProfileViews];

            if(err) {
                NSLog(@"Display non-obtrusive error somewhere");
            } else {
                if([[[self profile] type] isEqualToString:STKUserTypeInstitution]) {
                    [[STKUserStore store] fetchTrustsForUser:[self profile] completion:^(NSArray *trusts, NSError *err) {
                        NSMutableArray *lums = [NSMutableArray array];
                        for(STKTrust *t in [[self profile] ownedTrusts]) {
                            if([[t status] isEqualToString:STKRequestStatusAccepted])
                                [lums addObject:[t recepient]];
                        }
                        for(STKTrust *t in [[self profile] receivedTrusts]) {
                            if([[t status] isEqualToString:STKRequestStatusAccepted])
                                [lums addObject:[t creator]];
                        }
                        [self setLuminaries:lums];
                    }];
                } else {
                    if(![[self profile] isEqual:[[STKUserStore store] currentUser]]) {
                        [[STKUserStore store] fetchTrustForUser:[self profile] otherUser:[[STKUserStore store] currentUser]
                                                     completion:^(STKTrust *t, NSError *err) {
                                                         
                                                         [self refreshProfileViews];
                                                     }];
                    }
                }
            }
        }];
        
        [[STKContentStore store] fetchProfilePostsForUser:[self profile]
                                              inDirection:STKQueryObjectPageNewer
                                            referencePost:[[[self postController] posts] firstObject]
                                               completion:^(NSArray *posts, NSError *err) {
                                                   if(!err) {
                                                       [[self postController] addPosts:posts];
                                                       
                                                       [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:STKProfileSectionDynamic]
                                                                       withRowAnimation:UITableViewRowAnimationNone];
                                                   } else {
                                                       // Do nothing?
                                                   }
                                               }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isShowingInformation] && ![self isShowingLuminaries]) {
        
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
            [pvc setAllowPersonalFilter:[[self profile] isEqual:[[STKUserStore store] currentUser]]];
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
    
    [[[self filterView] gridViewButton] setSelected:YES];
}

- (void)scrollToPosts
{
    if([[[self postController] posts] count] > 0) {
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:STKProfileSectionDynamic]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:YES];
    }
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

- (IBAction)toggleFilterByUserPost:(id)sender atIndexPath:(NSIndexPath *)ip
{
}

- (IBAction)toggleFilterbyLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setFilterByLocation:![self filterByLocation]];
    [[[self filterView] locationButton] setSelected:[self filterByLocation]];
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
        STKPostCell *c = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:STKProfileSectionDynamic]];
        
        return [[self view] convertRect:[[c contentImageView] frame] fromView:[[c contentImageView] superview]];
    } else {
        int row = idx / 3;
        int offset = idx % 3;
        
        STKTriImageCell *c = (STKTriImageCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:STKProfileSectionDynamic]];
        
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

- (void)toggleInformation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self setShowingInformation:![self isShowingInformation]];
    [[self tableView] reloadData];
}

- (void)luminariesToggled:(id)sender
{
    [self setShowingLuminaries:![self isShowingLuminaries]];
    [[self tableView] reloadData];
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


- (void)refreshProfileViews
{
    STKUser *p = [self profile];
    [[[self profileView] nameLabel] setText:[p name]];
    if([p city] && [p state]) {
        NSString *city = [p city];
        NSString *state = [p state];
        [[[self profileView] locationLabel] setText:[NSString stringWithFormat:@"%@, %@", city, state]];
    } else
        [[[self profileView] locationLabel] setText:@""];
    
    [[[self profileView] coverPhotoImageView] setUrlString:[p coverPhotoPath]];
    [[[self profileView] avatarView] setUrlString:[p profilePhotoPath]];
    
    [[self profileView] setShowPrismImageForToggleButton:[self isShowingInformation]];
    
    STKInitialProfileStatisticsCell *c = [self statsView];
    if([self isShowingCurrentUserProfile]) {
        [[c accoladesButton] setHidden:NO];
        [[c followButton] setHidden:YES];
        [[c trustButton] setHidden:YES];
        [[c editButton] setHidden:NO];
        [[c messageButton] setHidden:YES];
        
        if([[[self profile] type] isEqualToString:STKUserTypeInstitution]) {
            [[c accoladesButton] setHidden:YES];
        }
    } else {
        
        [[c editButton] setHidden:YES];

        if([[[self profile] type] isEqualToString:STKUserTypeInstitution]) {
            [[c trustButton] setHidden:YES];
            [[c messageButton] setHidden:![MFMailComposeViewController canSendMail]];
        } else {
            [[c trustButton] setHidden:NO];
            [[c messageButton] setHidden:YES];
        }

        STKTrust *t = [[self profile] trustForUser:[[STKUserStore store] currentUser]];

        if([t isAccepted]) {
            [[c followButton] setHidden:YES];
            [[c accoladesButton] setHidden:NO];
            
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
            if([[[[STKUserStore store] currentUser] type] isEqualToString:STKUserTypeInstitution]) {
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
            if([self isShowingInformation]) {
                UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell-InfoHeader"];
                if(!c) {
                    c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell-InfoHeader"];
                    [[c contentView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
                    [[c textLabel] setFont:STKFont(14)];
                    [[c textLabel] setTextColor:STKTextColor];
                    [c setSelectionStyle:UITableViewCellSelectionStyleNone];
                    if([[[self profile] type] isEqualToString:STKUserTypeInstitution]) {
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        [btn setImage:[UIImage imageNamed:@"luminaries"] forState:UIControlStateNormal];
                        [btn setImage:[UIImage imageNamed:@"luminaries_active"] forState:UIControlStateSelected];
                        [btn addTarget:self action:@selector(luminariesToggled:) forControlEvents:UIControlEventTouchUpInside];
                        [btn setFrame:CGRectMake(320 - 25 - 12, 10, 25, 25)];
                        [[btn imageView] setContentMode:UIViewContentModeCenter];
                        [[btn imageView] setClipsToBounds:NO];
                        [btn setClipsToBounds:NO];
                        [[c contentView] addSubview:btn];
                        [self setLuminaryButton:btn];
                    }
                }
                if([self isShowingLuminaries])
                    [[c textLabel] setText:@"Luminaries"];
                else
                    [[c textLabel] setText:@"Information"];

                [[self luminaryButton] setSelected:[[self profile] hasTrusts]];
                
                return c;
            } else {
                return [self filterView];
            }
        }
    } else if([indexPath section] == STKProfileSectionDynamic) {
        if([self isShowingInformation]) {
            if([self isShowingLuminaries]) {
                STKLuminariesCell *c = [STKLuminariesCell cellForTableView:tableView target:self];
                [c setUsers:[self luminaries]];
                [[c contentView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
                return c;
            } else {
                if([indexPath row] == 0) {
                    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell-Info"];
                    if(!c) {
                        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell-Info"];
                        [[c contentView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
                        [[c textLabel] setFont:STKFont(12)];
                        [[c textLabel] setTextColor:STKTextColor];
                        [[c textLabel] setNumberOfLines:0];
                        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    [[c textLabel] setText:[[self profile] blurb]];
                    return c;
                } else {
                    STKInstitutionInfoCell *c = [STKInstitutionInfoCell cellForTableView:tableView target:self];
                    
                    NSString *label = nil;
                    NSString *text = nil;
                    if([indexPath row] == 1) {
                        label = @"Website:";
                        text = [[self profile] website];
                        
                    } else if([indexPath row] == 2) {
                        label = @"Founded:";
                        if([[self profile] dateFounded]) {
                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                            [df setDateFormat:@"MMMM dd, yyyy"];
                            text = [df stringFromDate:[[self profile] dateFounded]];
                        }
                        
                    } else if([indexPath row] == 3) {
                        label = @"Population:";
                        text = [[self profile] enrollment];
                    } else if([indexPath row] == 4) {
                        label = @"Mascot:";
                        text = [[self profile] mascotName];
                    }
                    
                    [[c titleLabel] setText:label];
                    [[c valueLabel] setText:text];
                    
                    return c;
                }

            }
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
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == STKProfileSectionStatic) {
        if([indexPath row] == 0)
            return 246;
        if([indexPath row] == 1)
            return 155;
        if([indexPath row] == 2) {
            if([self isShowingInformation]) {
                return 34;
            } else {
                return 50;
            }
        }
    } else if([indexPath section] == STKProfileSectionDynamic) {
        if([self isShowingInformation]) {
            if([self isShowingLuminaries]) {
                return 163;
            } else {
                if([indexPath row] == 0) {
                    return [self heightForInfoCell];
                } else {
                    return 44;
                }
            }
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
    CGRect r = [[[self profile] blurb] boundingRectWithSize:CGSizeMake(300, 10000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : f} context:nil];

    return r.size.height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == STKProfileSectionDynamic) {
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
            if([self isShowingLuminaries]) {
                return 1;
            } else {
                if([[[self profile] type] isEqualToString:STKUserTypeInstitution]) {
                    return 5;
                }
            
                return 1;
            }
        }
    }
    return 3;
}


@end
