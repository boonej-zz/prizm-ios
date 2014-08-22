//
//  STKSearchTrustsViewController   m
//  Prism
//
//  Created by Jesse Stevens Black on 6/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSearchUsersViewController.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKSearchTrustCell.h"
#import "STKTextImageCell.h"
#import "UIERealTimeBlurView.h"
#import "UIViewController+STKControllerItems.h"
#import "STKSearchProfileCell.h"
#import "STKProfileViewController.h"
#import "Mixpanel.h"
#import "STKFetchDescription.h"

@interface STKSearchUsersViewController ()

@property (nonatomic, assign) STKSearchUsersType searchType;
@property (nonatomic, strong) NSArray *filterPostOptions;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (nonatomic, strong) NSArray *profilesFound;

@end

@implementation STKSearchUsersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setTitle:@"Search"];
        [[self navigationItem] setLeftBarButtonItem:[self backButtonItem]];
        [self setSearchType:STKSearchUsersTypeNotInTrust];
    }
    return self;
}

- (id)initWithSearchType:(STKSearchUsersType)type
{
    self = [super init];
    if(self){
        [self setSearchType:type];
    }
    return self;
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self searchResultsTableView] setBackgroundColor:[UIColor clearColor]];
    [[self searchResultsTableView] setSeparatorColor:STKTextTransparentColor];
    [[self searchResultsTableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self searchResultsTableView] setTableFooterView:v];
    
    CGFloat tableContentInsetTop = [[self blurView] frame].size.height;
    [[self searchResultsTableView] setContentInset:UIEdgeInsetsMake(tableContentInsetTop, 0, 0, 0)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == [self searchResultsTableView])
        [[self searchTextField] resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self blurView] displayLink] setPaused:NO];
    [self reloadSearchResults];
    
    if ([self searchType] == STKSearchUsersTypeNotInTrust) {
        STKFetchDescription *fd = [[STKFetchDescription alloc] init];
        [fd setDirection:STKQueryObjectPageNewer];
        
        [[STKUserStore store] fetchTrustsForUser:[[STKUserStore store] currentUser] fetchDescription:fd completion:^(NSArray *trusts, NSError *err) {
            [self reloadSearchResults];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    
    [[self searchTextField] setText:nil];
}

- (IBAction)searchFieldDidChange:(UITextField *)sender
{
    NSString *searchString = [sender text];
    if([searchString length] < 2) {
        [self reloadSearchResults];
        return;
    }
    
    if([self searchType] == STKSearchUsersTypeNotInTrust) {
        [[STKUserStore store] searchUserNotInTrustWithName:searchString completion:^(NSArray *users, NSError *error) {
            if(!error && [users count] > 0){
                [self setProfilesFound:users];
                [self reloadSearchResults];
            }
        }];
    }else{
        [[STKUserStore store] searchUsersWithName:searchString completion:^(NSArray *profiles, NSError *err) {
            
//            if([self searchType] == STKSearchUsersNotInTrust){
//                STKUser *currentUser = [[STKUserStore store] currentUser];
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self != %@", currentUser];
//                profiles = [profiles filteredArrayUsingPredicate:predicate];
//                
//                NSMutableArray *trustless = [NSMutableArray array];
//                [profiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    STKUser *u = (STKUser *)obj;
//                    STKTrust *trust = [currentUser trustForUser:u];
//                    if (trust == nil || [trust isCancelled]) {
//                        [trustless addObject:u];
//                    }
//                }];
//                
//                [self setProfilesFound:trustless];
//            }else{
                [self setProfilesFound:profiles];
//            }
            
            [self reloadSearchResults];
        }];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self setProfilesFound:nil];
    [self reloadSearchResults];
    return YES;
}

- (void)reloadSearchResults
{
    [[self searchResultsTableView] reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self filterPostOptions] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[self filterPostOptions] objectAtIndex:[indexPath row]];
    STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                           forIndexPath:indexPath];
    [[cell label] setText:[item objectForKey:@"title"]];
    [[cell imageView] setImage:[item objectForKey:@"image"]];
    [cell setBackgroundColor:[UIColor clearColor]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[self profilesFound] count] == 0) {
        if([[[self searchTextField] text] length] >= 2)
            return 1;
        return 0;
    }
    
    return [[self profilesFound] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self profilesFound] count] == 0) {
        UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if(!c) {
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
            [[c textLabel] setTextColor:STKTextColor];
            [[c textLabel] setFont:STKFont(16)];
            [c setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        [[c textLabel] setText:@"No results found."];
        return c;
        
    }
    
    if([self searchType] == STKSearchUsersTypeNotInTrust){
        STKSearchTrustCell *c = [STKSearchTrustCell cellForTableView:tableView target:self];
        STKUser *u = [[self profilesFound] objectAtIndex:[indexPath row]];
        [[c nameLabel] setTextColor:STKTextColor];
        [[c nameLabel] setText:[u name]];
        [[c avatarView] setUrlString:[u profilePhotoPath]];

        STKUser *currentUser = [[STKUserStore store] currentUser];
        STKTrust *trust = [u trustForUser:currentUser];

        [self updateCell:c withTrust:trust];

        return c;
    
    }else{
        STKSearchProfileCell *cell = [STKSearchProfileCell cellForTableView:tableView target:self];
        STKUser *user = [[self profilesFound] objectAtIndex:[indexPath row]];
        [[cell nameLabel] setTextColor:STKTextColor];
        [[cell nameLabel] setText:[user name]];
        [[cell avatarView] setUrlString:[user profilePhotoPath]];
        [[cell cancelTrustButton] setHidden:YES];
        [[cell mailButton] setHidden:YES];
        [[cell luminaryIcon] setHidden:![user isLuminary]];

        if([user isEqual:[[STKUserStore store] currentUser]]) {
            [[cell followButton] setHidden:YES];
        } else {
            [[cell followButton] setHidden:NO];
            if([user isFollowedByUser:[[STKUserStore store] currentUser]]) {
                [[cell followButton] setSelected:YES];
            } else {
                [[cell followButton] setSelected:NO];
            }
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self searchResultsTableView]) {
        if([indexPath row] < [[self profilesFound] count]) {
            STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
            [pvc setProfile:[[self profilesFound] objectAtIndex:[indexPath row]]];
            [[self navigationController] pushViewController:pvc animated:YES];
            
        }
    }
}

- (void)updateCell:(STKSearchTrustCell *)c withTrust:(STKTrust *)trust
{
    if(!trust || [trust isCancelled]) {
        [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
    } else {
        if([trust isPending]) {
            if([[trust recepient] isEqual:[[STKUserStore store] currentUser]]) {
                [[c trustButton] setImage:[UIImage imageNamed:@"activity_accept_trust"] forState:UIControlStateNormal];
            } else {
                [[c trustButton] setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
            }
        } else if([trust isRejected]) {
            if([[trust recepient] isEqual:[[STKUserStore store] currentUser]]) {
                [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
            } else {
                [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
            }
        } else if([trust isAccepted]) {
            [[c trustButton] setImage:[UIImage imageNamed:@"btn_trust"] forState:UIControlStateNormal];
        }
    }
    
}

- (void)toggleTrust:(id)sender atIndexPath:(NSIndexPath*)indexPath
{
    STKUser *currentUser = [[STKUserStore store] currentUser];
    STKUser *u = [[self profilesFound] objectAtIndex:[indexPath row]];

    STKTrust *t = [currentUser trustForUser:u];
    
    if(!t || [t isCancelled]) {
        [[STKUserStore store] requestTrustForUser:u completion:^(STKTrust *requestItem, NSError *err) {
            if(err) {
                [[STKErrorStore alertViewForErrorWithOriginMessage:err delegate:nil] show];
            }
            [[self searchResultsTableView] reloadData];
        }];
    } else if([t isPending]) {
        if([[t recepient] isEqual:[[STKUserStore store] currentUser]]) {
            // Accept
            [[STKUserStore store] acceptTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                if (err) {
                    [[STKErrorStore alertViewForError:err delegate:nil] show];
                }
                [[self searchResultsTableView] reloadData];
            }];
        } else {
            [[STKUserStore store] cancelTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                if (err) {
                    [[STKErrorStore alertViewForError:err delegate:nil] show];
                }
                [[self searchResultsTableView] reloadData];
            }];
        }
    } else if([t isRejected]) {
        if([[t recepient] isEqual:[[STKUserStore store] currentUser]]) {
            // Do nothing, is rejected
        } else {
            [[STKUserStore store] cancelTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
                if (err) {
                    [[STKErrorStore alertViewForError:err delegate:nil] show];
                }
                [[self searchResultsTableView] reloadData];
            }];
        }
    } else if([t isAccepted]) {
        // do nothing!
    }

    [[self searchResultsTableView] reloadData];
}

- (void)toggleFollow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *u = [[self profilesFound] objectAtIndex:[ip row]];
    if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[STKUserStore store] unfollowUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self searchResultsTableView] cellForRowAtIndexPath:ip] followButton] setSelected:NO];
                [self trackUnfollow:u];
            } else {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }];
    } else {
        [[STKUserStore store] followUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self searchResultsTableView] cellForRowAtIndexPath:ip] followButton] setSelected:YES];
                [self trackFollow:u];
            } else {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }];
    }
    
}

- (void)trackViewUser:(STKUser *)user
{
    
    [[Mixpanel sharedInstance] track:@"Search result - view user" properties:mixpanelDataForObject(@{@"Search filter" : [self searchTypeString],
                                                                                   @"Search term" : [[self searchTextField] text],
                                                                                   @"Found user" : user.email
                                                                                   })];
}

- (void)trackUnfollow:(STKUser *)user
{
    
    [[Mixpanel sharedInstance] track:@"Search result - unfollow user" properties:mixpanelDataForObject(@{@"Search filter" : [self searchTypeString],
                                                                                   @"Search term" : [[self searchTextField] text],
                                                                                   @"Found user" : user.email
                                                                                   })];
}

- (void)trackFollow:(STKUser *)user
{
    
    [[Mixpanel sharedInstance] track:@"Search result - follow user" properties:mixpanelDataForObject(@{@"Search filter" : [self searchTypeString],
                                                                                   @"Search term" : [[self searchTextField] text],
                                                                                   @"Found user" : user.email
                                                                                   })];
}

- (NSString *)searchTypeString
{
    NSDictionary *map = @{@(STKSearchUsersTypeToFollow) : @"user to follow",
                          @(STKSearchUsersTypeNotInTrust) : @"user to trust"};
    
    return map[@([self searchType])];
}

@end
