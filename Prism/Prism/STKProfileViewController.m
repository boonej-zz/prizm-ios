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

@interface STKProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STKProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_user"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_user_selected"]];
    }
    return self;
}

- (IBAction)temporaryLogout:(id)sender
{
    [[self menuController] logout];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[STKUserStore store] fetchProfileForCurrentUser:^(STKUser *u, NSError *err) {
        [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                        withRowAnimation:UITableViewRowAnimationNone];
    }];
    [[STKContentStore store] fetchProfilePostsForCurrentUser:^(NSArray *posts, NSError *err, BOOL moreComing) {
        if(!err) {
            _posts = posts;
        }
        if(moreComing) {
            [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:2]
                           withRowAnimation:UITableViewRowAnimationNone];
        } else {
            
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setDelaysContentTouches:NO];
}

- (void)leftImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    
}

- (void)centerImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    
}

- (void)rightImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    
}

- (float)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
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
    STKProfile *p = [[[STKUserStore store] currentUser] personalProfile];
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
    [[c circleView] setCircleTitles:@[@"Followers", @"Following", @"Posts"]];
    [[c circleView] setCircleValues:@[@"0", @"0", @"0"]];
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
