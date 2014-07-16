//
//  STKTrustViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTrustViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTrustView.h"
#import "STKCountView.h"
#import "STKUserStore.h"
#import "STKImageStore.h"
#import "STKUser.h"
#import "STKRenderServer.h"
#import "STKUserListViewController.h"
#import "STKProfileViewController.h"
#import "STKTrust.h"
#import "STKUserPostListViewController.h"
#import "STKFetchDescription.h"
#import "STKOptionCell.h"
#import "STKNavigationButton.h"
#import "STKSearchUsersViewController.h"

@import MessageUI;

@interface STKTrustViewController ()
    <STKTrustViewDelegate, MFMailComposeViewControllerDelegate, STKCountViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *selectedNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet STKTrustView *trustView;
@property (weak, nonatomic) IBOutlet STKCountView *countView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *underlayView;
@property (nonatomic, strong) NSArray *trusts;
@property (weak, nonatomic) IBOutlet UIImageView *numberImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *trustTypeCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionConstraint;
@property (nonatomic, strong) UIControl *overlayView;
@property (weak, nonatomic) IBOutlet UIView *trustTypeContainer;
@property (weak, nonatomic) IBOutlet UIImageView *trustTypeBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *trustTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *instructionsView;

@property (nonatomic, weak) STKUser *selectedUser;
@property (nonatomic, strong) NSArray *trustTypes;

@property (nonatomic) BOOL saveTrustSelection;

- (IBAction)showList:(id)sender;
- (IBAction)sendEmail:(id)sender;

@property (nonatomic, strong) UIBarButtonItem *addTrustBarButtonItem;
@end

@implementation STKTrustViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Trust"];

        STKNavigationButton *view = [[STKNavigationButton alloc] init];
        [view setImage:[UIImage imageNamed:@"addusertrust"]];
        [view setOffset:8];
        
        [view addTarget:self action:@selector(addNewTrust:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
        [[self navigationItem] setRightBarButtonItem:bbi];
        [self setAddTrustBarButtonItem:bbi];
        
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_trust"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_trust_selected"]];
        [[self tabBarItem] setTitle:@"Trust"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserChanged:) name:STKUserStoreCurrentUserChangedNotification object:nil];
        [self setTrustTypes:@[STKTrustTypeMentor, STKTrustTypeParent, STKTrustTypeFriend,
                              STKTrustTypeCoach, STKTrustTypeTeacher, STKTrustTypeFamily]];
    }
    return self;
}

- (void)addNewTrust:(id)sender
{
    STKSearchUsersViewController *searchController = [[STKSearchUsersViewController alloc] init];
    [searchController setTitle:@"Add to Trust"];
    [[self navigationController] pushViewController:searchController animated:YES];
    [[self menuController] setMenuVisible:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self countView] setCircleTitles:@[@"Likes", @"Comments", @"Posts"]];
    [[self countView] setCircleValues:@[@"0", @"0", @"0"]];
    [[self countView] setDelegate:self];
    
    [[self trustView] setDelegate:self];

    [[self dateLabel] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    [[self dateLabel] setClipsToBounds:YES];
    [[[self dateLabel] layer] setCornerRadius:2];
    
    [[self trustTypeCollectionView] registerNib:[UINib nibWithNibName:@"STKOptionCell" bundle:nil]
                     forCellWithReuseIdentifier:@"STKOptionCell"];
    [[self trustTypeCollectionView] setBackgroundColor:[UIColor clearColor]];
    
}

- (void)currentUserChanged:(NSNotification *)note
{
    if([[[STKUserStore store] currentUser] isInstitution]) {
        [[self tabBarItem] setTitle:@"Luminary"];
        [[self navigationItem] setTitle:@"Luminary"];
    } else {
        [[self tabBarItem] setTitle:@"Trust"];
        [[self navigationItem] setTitle:@"Trust"];
    }
}

- (void)countView:(STKCountView *)countView didSelectCircleAtIndex:(int)index
{
    if(![self selectedUser])
        return;
    
    STKTrust *t = [[self trusts] objectAtIndex:[[[self trustView] users] indexOfObject:[self selectedUser]]];
    NSString *otherName = [[t otherUser] name];
    
    STKUserPostListViewController *pvc = [[STKUserPostListViewController alloc] initWithTrust:t];
    [pvc setShowsFilterBar:NO];
    [pvc setTitle:otherName];
    if(index == 0) {
        [pvc setTrustType:STKTrustPostTypeLikes];
    } else if(index == 1) {
        [pvc setTrustType:STKTrustPostTypeComments];
    } else if(index == 2) {
        [pvc setTrustType:STKTrustPostTypeTags];
    }
    
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)trustView:(STKTrustView *)tv didSelectCircleAtIndex:(int)idx
{
    [self setSaveTrustSelection:YES];
    [self selectUserAtIndex:idx];
}

- (void)selectUserAtIndex:(int)idx
{
    if(idx >= 0 && idx < [[self trusts] count]) {
        STKUser *u = [[[self trustView] users] objectAtIndex:idx];
        if([[u uniqueID] isEqualToString:[[self selectedUser] uniqueID]]) {
            STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
            [pvc setProfile:u];
            [[self navigationController] pushViewController:pvc animated:YES];
            return;
        }
        [self setSelectedUser:u];
        [self configureInterface];
    }
}

- (void)configureInterface
{
    NSLog(@"configure interface trust count %u", [[[self trustView] users] count]);
    [[self instructionsView] setHidden:![[[STKUserStore store] currentUser] shouldDisplayTrustInstructions]];
    
    if([self selectedUser]) {
        NSUInteger idx = [[[self trustView] users] indexOfObject:[self selectedUser]];

        // select top trust when current selection falls off screen
        if(idx >= [[self trusts] count] || idx >= 5) {
            idx = 0;
        }

        if(idx == NSNotFound) {
            [self setSelectedUser:nil];
        } else {
            [[self selectedNameLabel] setText:[[self selectedUser] name]];
            [[self trustTypeLabel] setText:[STKTrust titleForTrustType:[[self selectedTrust] type]]];
            [[self trustView] setSelectedIndex:idx + 1];
            
            NSDictionary *lookup = @{@(0) : @"trust_one",
                                     @(1) : @"trust_two",
                                     @(2) : @"trust_three",
                                     @(3) : @"trust_four",
                                     @(4) : @"trust_five"};
            UIImage *img = [UIImage imageNamed:[lookup objectForKey:@(idx)]];
            [[self numberImageView] setImage:img];
            
            NSDate *dateCreated = [[self selectedUser] dateCreated];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MMM yyyy"];
            [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [[self dateLabel] setText:[NSString stringWithFormat:@" Member Since %@ ", [df stringFromDate:dateCreated]]];
            
            STKTrust *t = [[self trusts] objectAtIndex:idx];
            
            int lCount = 0, cCount, pCount = 0;
            if([[[t creator] uniqueID] isEqualToString:[[[STKUserStore store] currentUser] uniqueID]]) {
                lCount = [t recepientLikesCount];
                cCount = [t recepientCommentsCount];
                pCount = [t recepientPostsCount];
            } else {
                lCount = [t creatorLikesCount];
                cCount = [t creatorCommentsCount];
                pCount = [t creatorPostsCount];
                
            }
            [[self countView] setCircleValues:@[
                [NSString stringWithFormat:@"%d", lCount],
                [NSString stringWithFormat:@"%d", cCount],
                [NSString stringWithFormat:@"%d", pCount]
            ]];
        }
        
    }
    
    if(![self selectedUser]) {
        [[self selectedNameLabel] setText:nil];
        [[self trustView] setSelectedIndex:0];
        [[self dateLabel] setText:nil];
        [[self numberImageView] setImage:nil];

        [[self countView] setCircleValues:@[@"0", @"0", @"0"]];
    }

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self trustView] setUser:[[STKUserStore store] currentUser]];
    
    if(![[self backgroundImageView] image]) {
        [[STKImageStore store] fetchImageForURLString:[[[STKUserStore store] currentUser] profilePhotoPath] preferredSize:STKImageStoreThumbnailSmall completion:^(UIImage *img) {
            UIGraphicsBeginImageContext(CGSizeMake(80, 80));
            [img drawInRect:CGRectMake(0, 0, 80, 80)];
            UIImage *blurredImage = [[STKRenderServer renderServer] blurredImageWithImage:UIGraphicsGetImageFromCurrentImageContext() affineClamp:YES];
            [[self backgroundImageView] setImage:blurredImage];
            UIGraphicsEndImageContext();
        }];
    }
    
    [[STKUserStore store] fetchTopTrustsForUser:[[STKUserStore store] currentUser] completion:^(NSArray *trusts, NSError *err) {
        [self setTrusts:trusts];
        NSMutableArray *otherUsers = [[NSMutableArray alloc] init];
        for(STKTrust *t in [self trusts]) {
            
            if([[t creator] isEqual:[[STKUserStore store] currentUser]]) {
                [otherUsers addObject:[t recepient]];
            } else {
                [otherUsers addObject:[t creator]];
            }
        }
        NSLog(@"other users count %d", [otherUsers count]);
        [[self trustView] setUsers:otherUsers];
        if([[self trusts] count] > 0) {
            
            if ([self saveTrustSelection] == NO && [self selectedUser] != [[[self trustView] users] objectAtIndex:0]) {
                //overwrite selection with highest ranged
                [self selectUserAtIndex:0];
            } else if (![self selectedUser]) {
                [self selectUserAtIndex:0];
            } else {
                [self configureInterface];
            }
        } else {
            [self configureInterface];
        }
    }];
    
    [self configureInterface];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissTrustMenu:nil];
}

- (STKTrust *)selectedTrust
{
    for(STKTrust *t in [self trusts]) {
        if([[[t otherUser] uniqueID] isEqualToString:[[self selectedUser] uniqueID]]) {
            return t;
        }
    }
    return nil;
}

- (IBAction)promptTitleChange:(id)sender
{
    if([self selectedUser]) {
        UIImage *img = [[STKRenderServer renderServer] instantBlurredImageForView:[self view]
                                                                        inSubrect:CGRectMake(0, [[self view] bounds].size.height - 100, 320, 100)];
        [[self trustTypeBackgroundImageView] setImage:img];
        
        [[self trustTypeCollectionView] reloadData];
        [[self trustTypeCollectionView] setBackgroundColor:[UIColor clearColor]];
        
        _overlayView = [[UIControl alloc] initWithFrame:[[self view] bounds]];
        [[self overlayView] addTarget:self action:@selector(dismissTrustMenu:) forControlEvents:UIControlEventTouchUpInside];
        [[self overlayView] setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [[self view] insertSubview:[self overlayView] belowSubview:[self trustTypeContainer]];
        
        [[self optionConstraint] setConstant:0];
        [UIView animateWithDuration:0.2 animations:^{
            [[self view] layoutIfNeeded];
        }];

    }
}

- (void)dismissTrustMenu:(id)sender
{
    [[self optionConstraint] setConstant:-[[self trustTypeCollectionView] bounds].size.height];
    [[self overlayView] removeFromSuperview];
    [self setOverlayView:nil];
    
    [UIView animateWithDuration:0.2 animations:^{
        [[self view] layoutIfNeeded];
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)menuWillAppear:(BOOL)animated
{
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            [[self underlayView] setAlpha:0.5];
        }];
    } else {
        [[self underlayView] setAlpha:0.5];
    }
    [[self navigationItem] setRightBarButtonItem:nil];
}

- (void)menuWillDisappear:(BOOL)animated
{
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            [[self underlayView] setAlpha:0.0];
        }];
    } else {
        [[self underlayView] setAlpha:0.0];
    }
    [[self navigationItem] setRightBarButtonItem:[self addTrustBarButtonItem]];
}


- (IBAction)showList:(id)sender
{
    STKUserListViewController *lvc = [[STKUserListViewController alloc] init];
    if([[[STKUserStore store] currentUser] isInstitution]) {
        [lvc setTitle:@"Luminary"];
    } else {
        [lvc setTitle:@"Trusts"];
    }
    
    [lvc setType:STKUserListTypeTrust];
    
    [[self navigationController] pushViewController:lvc animated:YES];
    
    
    STKFetchDescription *fd = [[STKFetchDescription alloc] init];
    [fd setFilterDictionary:@{@"status" : STKRequestStatusAccepted}];
    [fd setDirection:STKQueryObjectPageNewer];

    [[STKUserStore store] fetchTrustsForUser:[[STKUserStore store] currentUser] fetchDescription:fd completion:^(NSArray *trusts, NSError *err) {
        NSMutableArray *otherUsers = [[NSMutableArray alloc] init];
        for(STKTrust *t in trusts) {
            if([[t creator] isEqual:[[STKUserStore store] currentUser]]) {
                [otherUsers addObject:[t recepient]];
            } else {
                [otherUsers addObject:[t creator]];
            }
        }
        
        NSSortDescriptor *alphabetic = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortedUsers = [otherUsers sortedArrayUsingDescriptors:@[alphabetic]];
        [lvc setUsers:sortedUsers];
    }];

}

- (IBAction)sendEmail:(id)sender
{
    if(![self selectedUser]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Select a User" message:@"Select a user from your trust to send them a message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Configure Mail"
                                                     message:[NSString stringWithFormat:@"To send an e-mail to %@, configure a mail account in your device's settings.", [[self selectedUser] name]]
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }

    if(![[self selectedUser] email]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No E-mail" message:@"This user doesn't have an e-mail account available in Prizm." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    MFMailComposeViewController *mvc = [[MFMailComposeViewController alloc] init];
    [mvc setMailComposeDelegate:self];
    [mvc setToRecipients:@[[[self selectedUser] email]]];
    [mvc setSubject:@"Prizm Contact"];
    [self presentViewController:mvc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(error) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *type = [[self trustTypes] objectAtIndex:[indexPath row]];
    [[self selectedTrust] setType:type];
    [[self trustTypeCollectionView] reloadData];
    [self configureInterface];
    [[STKUserStore store] updateTrust:[self selectedTrust] toType:type completion:^(STKTrust *requestItem, NSError *err) {
        
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissTrustMenu:nil];
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self trustTypes] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STKOptionCell *c = (STKOptionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKOptionCell"
                                                                 forIndexPath:indexPath];
    [c setBackgroundColor:[UIColor clearColor]];
    [[c contentView] setBackgroundColor:STKUnselectedColor];
    [[c textLabel] setTextColor:[UIColor whiteColor]];
    
    if([[[self selectedTrust] type] isEqualToString:[[self trustTypes] objectAtIndex:[indexPath row]]]) {
        [[c contentView] setBackgroundColor:STKSelectedColor];
        [[c textLabel] setTextColor:STKSelectedTextColor];
    }
    
    NSString *title = [STKTrust titleForTrustType:[[self trustTypes] objectAtIndex:[indexPath item]]];
    [[c textLabel] setText:title];

    return c;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
