//
//  STKUserListViewController.m
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKUserListViewController.h"
#import "STKSearchProfileCell.h"
#import "STKUser.h"
#import "STKProfileViewController.h"
#import "UIERealTimeBlurView.h"
#import "STKUserStore.h"
#import "STKErrorStore.h"

@import MessageUI;

@interface STKUserListViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (nonatomic, strong) STKUser *deletingUser;
@end

@implementation STKUserListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    return self;
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    [[self tableView] reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];
    
    [[[self blurView] displayLink] setPaused:NO];
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

- (void)toggleFollow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *u = [[self users] objectAtIndex:[ip row]];
    if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[STKUserStore store] unfollowUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self tableView] cellForRowAtIndexPath:ip] followButton] setSelected:NO];
            } else {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }];
    } else {
        [[STKUserStore store] followUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self tableView] cellForRowAtIndexPath:ip] followButton] setSelected:YES];
            } else {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }];
    }
}

- (void)cancelTrust:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *u = [[self users] objectAtIndex:[ip row]];
    [self setDeletingUser:u];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", "confirm cancel trust title")
                                                 message:[NSString stringWithFormat:NSLocalizedString(@"Confirming this action will remove %@ from your trust.", "confirm cancel trust message"), [u name]]
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel confirmed action button title")
                                       otherButtonTitles:NSLocalizedString(@"Confirm", @"confirm button"), nil];
    [av show];
}

- (void)sendMessage:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *u = [[self users] objectAtIndex:[ip row]];
    MFMailComposeViewController *mvc = [[MFMailComposeViewController alloc] init];
    [mvc setMailComposeDelegate:self];
    [mvc setToRecipients:@[[u email]]];
    [mvc setSubject:@"Prizm Contact"];
    [self presentViewController:mvc animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self setDeletingUser:nil];
    } else {
        
        NSArray *prevUsers = [self users];
        [self setUsers:[[self users] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uniqueID != %@", [[self deletingUser] uniqueID]]]];
        
        STKTrust *t = [[[STKUserStore store] currentUser] trustForUser:[self deletingUser]];
        [[STKUserStore store] cancelTrustRequest:t completion:^(STKTrust *requestItem, NSError *err) {
            if(err) {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
                [self setUsers:prevUsers];
            }
            [[self tableView] reloadData];
        }];
        [[self tableView] reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];
    [[self tableView] setContentInset:UIEdgeInsetsMake(65, 0, 0, 0)];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:v];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
    [pvc setProfile:[[self users] objectAtIndex:[indexPath row]]];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self users] count];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(error) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Send Error", @"send error title")
                                                     message:[error localizedDescription]
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                           otherButtonTitles:nil];
        [av show];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKUser *u = [[self users] objectAtIndex:[indexPath row]];
    STKSearchProfileCell *c = [STKSearchProfileCell cellForTableView:tableView target:self];
    
    [[c nameLabel] setTextColor:STKTextColor];
    [[c nameLabel] setText:[u name]];
    [[c avatarView] setUrlString:[u profilePhotoPath]];
    [[c luminaryIcon] setHidden:![u isLuminary]];

    if([self type] == STKUserListTypeFollow) {
        if([u isEqual:[[STKUserStore store] currentUser]]) {
            [[c followButton] setHidden:YES];
        } else {
            [[c followButton] setHidden:NO];
            if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
                [[c followButton] setSelected:YES];
            } else {
                [[c followButton] setSelected:NO];
            }
        }
    } else {
        [[c followButton] setHidden:YES];
        [[c cancelTrustButton] setHidden:NO];
        if([u email] && [MFMailComposeViewController canSendMail]) {
            [[c mailButton] setHidden:NO];
        } else {
            [[c mailButton] setHidden:YES];
        }
    }
    
    return c;
}


@end
