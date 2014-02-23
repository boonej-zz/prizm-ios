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
#import "STKProfile.h"
#import "STKBaseStore.h"
#import "STKPostViewController.h"
#import "STKRequestItem.h"
#import "STKEditProfileViewController.h"
#import "UIERealTimeBlurView.h"

@interface STKProfileViewController () <UITableViewDataSource, UITableViewDelegate, STKCountViewDelegate>
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;

@property (nonatomic, strong) NSMutableArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

- (BOOL)isShowingCurrentUserProfile
{
    return [[[self profile] profileID] isEqualToString:[[[[STKUserStore store] currentUser] personalProfile] profileID]];
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
        [self setProfile:[[[STKUserStore store] currentUser] personalProfile]];
    }
    
    if([self isShowingCurrentUserProfile]) {
        [[self navigationItem] setRightBarButtonItem:[self settingsBarButtonItem]];
        [[self navigationItem] setTitle:@"Profile"];
    } else {
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self navigationItem] setTitle:@"Prism"];
    }
    
    [[STKUserStore store] fetchProfile:[self profile] completion:^(STKProfile *p, NSError *err) {
        [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                        withRowAnimation:UITableViewRowAnimationNone];
    }];

    [[STKContentStore store] fetchProfilePostsForProfile:[self profile]
                                             inDirection:STKContentStoreFetchDirectionNewer
                                           referencePost:[[self posts] firstObject]
                                              completion:^(NSArray *posts, NSError *err) {
                                                  if(!err) {
                                                      [[self posts] addObjectsFromArray:posts];
                                                      [[self posts] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
                                                      [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:2]
                                                                      withRowAnimation:UITableViewRowAnimationNone];
                                                      
                                                  } else {
                                                      // Do nothing?
                                                  }
                                              }];
    
    
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
    [[self tableView] setDelaysContentTouches:NO];
}

- (void)scrollToPosts
{
    if([[self posts] count] > 0)
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)avatarTappedForPostAtIndex:(int)idx
{
    STKPost *p = [[self posts] objectAtIndex:idx];
    if([[[p creatorProfile] profileID] isEqualToString:[[self profile] profileID]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // Needs testing
        STKProfileViewController *nextProfile = [[STKProfileViewController alloc] init];
        [nextProfile setProfile:[p creatorProfile]];
        [[self navigationController] pushViewController:nextProfile animated:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)menuWillDisappear:(BOOL)animated
{
    [[self blurView] setOverlayOpacity:0.0];
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

- (void)requestTrust:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[STKUserStore store] createRequestOfType:STKRequestTypeTrust profile:[self profile] completion:^(id obj, NSError *err) {
        
    }];
}

- (void)follow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[STKUserStore store] startFollowingProfile:[self profile] completion:^(id obj, NSError *err) {
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 246;
    } else if([indexPath section] == 1) {
        return 213;
    } else if([indexPath section] == 2) {
        return 106;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   // if([indexPath section] == 0 || [indexPath section] == 1) {
        [cell setBackgroundColor:[UIColor clearColor]];
   // }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 246;
    } else if([indexPath section] == 1) {
        return 213;
    } else if([indexPath section] == 2) {
        return 106;
    }
    return 44;

}

- (void)populateProfileCell:(STKProfileCell *)c
{
    STKProfile *p = [self profile];
    [[c nameLabel] setText:[p name]];
    if([p city] && [p state]) {
        NSString *city = [p city];
        NSString *stateCode = [p state];
        NSString *state = [[STKBaseStore store] labelForCode:stateCode type:STKLookupTypeRegion];
        [[c locationLabel] setText:[NSString stringWithFormat:@"%@, %@", city, state]];
    } else
        [[c locationLabel] setText:@""];
    
    [[c coverPhotoImageView] setUrlString:[p coverPhotoPath]];
    [[c avatarView] setUrlString:[p profilePhotoPath]];
    
}

- (void)populateInitialProfileStatisticsCell:(STKInitialProfileStatisticsCell *)c
{
    if([self isShowingCurrentUserProfile]) {
        [[c followButton] setHidden:YES];
        [[c trustButton] setHidden:YES];
        [[c editButton] setHidden:NO];
    } else {
        [[c followButton] setHidden:NO];
        [[c trustButton] setHidden:NO];
        [[c editButton] setHidden:YES];
    }
    
    
    [[c circleView] setCircleTitles:@[@"Followers", @"Following", @"Posts"]];

    NSString *followerCount = [[self profile] followedCount];
    NSString *followingCount = [[self profile] followingCount];
    NSString *postCount = [[self profile] postCount];
    if(!followerCount)
        followerCount = @"0";
    if(!followingCount)
        followingCount = @"0";
    if(!postCount)
        postCount = @"0";
    
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
    if([indexPath section] == 0) {
        STKProfileCell *c = [STKProfileCell cellForTableView:tableView target:self];
        
        [self populateProfileCell:c];
        
        return c;
    } else if ([indexPath section] == 1) {
        STKInitialProfileStatisticsCell *c = [STKInitialProfileStatisticsCell cellForTableView:tableView target:self];
        [self populateInitialProfileStatisticsCell:c];
        return c;
    } else if([indexPath section] == 2) {
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:self];
        [self populateTriImageCell:c forRow:[indexPath row]];

        return c;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 2) {
        if([[self posts] count] % 3 > 0)
            return [[self posts] count] / 3 + 1;
        return [[self posts] count] / 3;
    }
    return 1;
}

@end
