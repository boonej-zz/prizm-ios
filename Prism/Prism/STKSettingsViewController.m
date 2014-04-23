//
//  STKSettingsViewController.m
//  Prism
//
//  Created by Joe Conway on 4/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSettingsViewController.h"
#import "STKInstagramAuthViewController.h"
#import "STKLabelCell.h"
#import "STKSettingsShareCell.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKNetworkStore.h"
#import "STKProcessingView.h"
#import "STKAccountChooserViewController.h"

@import Social;
@import Accounts;

@interface STKSettingsViewController () <STKAccountChooserDelegate>

@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, weak) UIButton *logoutButton;

@end

@implementation STKSettingsViewController


- (id)initWithItems:(NSArray *)items
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        
        [bbi setTitleTextAttributes:@{NSForegroundColorAttributeName : STKTextColor, NSFontAttributeName : STKFont(16)} forState:UIControlStateNormal];

        [[self navigationItem] setRightBarButtonItem:bbi];
        [[self navigationItem] setTitle:@"Settings"];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        [self setSettings:items];
        if(![self settings]) {
            _settings = @[
                          @{@"title": @"Sharing", @"type" : @"STKLabelCell", @"next" : [self sharingSettings]},
                          @{@"title" : @"Notifications", @"type" : @"STKLabelCell", @"next" : [self notificationSettings]}
                          ];
        }
    }
    return self;
}

- (NSArray *)notificationSettings
{
    return @[];
}

- (NSArray *)sharingSettings
{
    
    return
    @[
      @{@"title": @"Instagram", @"type" : @"STKSettingsShareCell", @"selectionSelector" : @"configureInstagram:", @"configure": ^(STKUser *u, UITableViewCell *cell) {
          [[(STKSettingsShareCell *)cell toggleSwitch] setOn:([u instagramToken] != nil)];
      }},
      @{@"title": @"Twitter", @"type" : @"STKSettingsShareCell", @"selectionSelector" : @"configureTwitter:", @"configure": ^(STKUser *u, UITableViewCell *cell) {
          [[(STKSettingsShareCell *)cell toggleSwitch] setOn:([u twitterID] != nil)];
      }}
    ];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithItems:nil];
}



- (void)accountChooser:(STKAccountChooserViewController *)chooser didChooseAccount:(ACAccount *)account
{
    [[[STKUserStore store] currentUser] setTwitterID:[account username]];

    [STKProcessingView present];
    [[STKUserStore store] updateUserDetails:[[STKUserStore store] currentUser] completion:^(STKUser *u, NSError *err) {
        [STKProcessingView dismiss];
        if(err) {
            UIAlertView *av = [STKErrorStore alertViewForError:err delegate:nil];
            [av show];
        }
        
        [[self navigationController] popViewControllerAnimated:YES];
    }];
}

- (void)configureTwitter:(NSNumber *)activating
{
    if([activating boolValue]) {
        [STKProcessingView present];
        [[STKUserStore store] fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
            if(err) {
                [STKProcessingView dismiss];
                UIAlertView *av = [STKErrorStore alertViewForError:err delegate:nil];
                [av show];
                return;
            }
            
            if([accounts count] == 0) {
                [STKProcessingView dismiss];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Twitter Account"
                                                             message:@"You do not have a Twitter account configured for this device. Use the Settings application to securely enter your Twitter credentials before giving Prizm access."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                return;
            }
            
            if([accounts count] == 1) {
                [[[STKUserStore store] currentUser] setTwitterID:[[accounts firstObject] username]];
                
                [STKProcessingView present];
                [[STKUserStore store] updateUserDetails:[[STKUserStore store] currentUser] completion:^(STKUser *u, NSError *err) {
                    [STKProcessingView dismiss];
                    if(err) {
                        UIAlertView *av = [STKErrorStore alertViewForError:err delegate:nil];
                        [av show];
                    }
                    
                    [[self navigationController] popViewControllerAnimated:YES];
                }];
            } else {
                [STKProcessingView dismiss];
                STKAccountChooserViewController *cvc = [[STKAccountChooserViewController alloc] initWithAccounts:accounts];
                [cvc setBackgroundImage:[UIImage imageNamed:@"img_background"]];
                [cvc setDelegate:self];
                [[self navigationController] pushViewController:cvc animated:YES];
            }
        }];
    } else {
        
    }
}

- (void)toggleNetwork:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSString *selName = [self selectionSelectorForIndexPath:ip];
    if(selName) {
        [self performSelector:NSSelectorFromString(selName) withObject:@([sender isOn])];
        return;
    }
}


- (void)configureInstagram:(NSNumber *)activating
{
    STKInstagramAuthViewController *vc = [[STKInstagramAuthViewController alloc] init];
    [vc setTokenFound:^(NSString *token) {
        if(token) {
            [[[STKUserStore store] currentUser] setInstagramToken:token];
            [[STKUserStore store] updateUserDetails:[[STKUserStore store] currentUser] completion:^(STKUser *u, NSError *err) {
                
            }];
        }
    }];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)done:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [[b titleLabel] setFont:STKFont(18)];
    [[b titleLabel] setTextColor:STKTextColor];
    [b addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [b setBackgroundImage:[UIImage imageNamed:@"btn_lg"] forState:UIControlStateNormal];
    [b setTitle:@"Logout" forState:UIControlStateNormal];
    [b setFrame:CGRectMake(10, 10, 300, 51)];
    [v addSubview:b];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:v];
    [[self tableView] setContentInset:UIEdgeInsetsMake(65, 0, 0, 0)];
    
    [self setLogoutButton:b];

}

- (void)logout:(id)sender
{
    [[STKUserStore store] logout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSFontAttributeName : STKFont(18), NSForegroundColorAttributeName : STKTextColor}];
    [[[self navigationController] navigationBar] setTintColor:STKTextColor];
    
    if([[[self navigationController] viewControllers] indexOfObject:self] != 0) {
        [[self logoutButton] setHidden:YES];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                                  landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(back:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];

    }
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
}

- (NSDictionary *)settingsItemAtIndexPath:(NSIndexPath *)ip
{
    return [[self settings] objectAtIndex:[ip row]];
}

- (NSString *)cellTypeForIndexPath:(NSIndexPath *)ip
{
    return [[self settingsItemAtIndexPath:ip] objectForKey:@"type"];
}

- (NSString *)titleForIndexPath:(NSIndexPath *)ip
{
    return [[self settingsItemAtIndexPath:ip] objectForKey:@"title"];
}

- (NSArray *)nextItemsForIndexPath:(NSIndexPath *)ip
{
    return [[self settingsItemAtIndexPath:ip] objectForKey:@"next"];
}

- (void (^)(STKUser *, UITableViewCell *))configureBlockForIndexPath:(NSIndexPath *)ip
{
    return [[self settingsItemAtIndexPath:ip] objectForKey:@"configure"];
}

- (Class)viewControllerClassForIndexPath:(NSIndexPath *)ip
{
    return [[self settingsItemAtIndexPath:ip] objectForKey:@"viewController"];
}

- (NSString *)selectionSelectorForIndexPath:(NSIndexPath *)ip
{
    return [[self settingsItemAtIndexPath:ip] objectForKey:@"selectionSelector"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nextItems = [self nextItemsForIndexPath:indexPath];
    if(nextItems) {
        STKSettingsViewController *svc = [[STKSettingsViewController alloc] initWithItems:nextItems];
        [[self navigationController] pushViewController:svc animated:YES];
        return;
    }
    
    Class cls = [self viewControllerClassForIndexPath:indexPath];
    if(cls) {
        UIViewController *vc = [[cls alloc] init];
        [[self navigationController] pushViewController:vc animated:YES];
        return;
    }
    
    NSString *selName = [self selectionSelectorForIndexPath:indexPath];
    if(selName) {
        [self performSelector:NSSelectorFromString(selName) withObject:self];
        return;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self settings] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = [self cellTypeForIndexPath:indexPath];
    
    UITableViewCell *returnCell = nil;
    
    if([cellType isEqualToString:@"STKLabelCell"]) {
        STKLabelCell *cell = [STKLabelCell cellForTableView:tableView target:self];
        [[cell overlayView] setBackgroundColor:[UIColor clearColor]];
        [[cell label] setText:[self titleForIndexPath:indexPath]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        returnCell = cell;
    }
    if([cellType isEqualToString:@"STKSettingsShareCell"]) {
        STKSettingsShareCell *cell = [STKSettingsShareCell cellForTableView:tableView target:self];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [[cell networkTitleLabel] setText:[self titleForIndexPath:indexPath]];
        returnCell = cell;
    }
    
    void (^configureBlock)(STKUser *u, UITableViewCell *c) = [self configureBlockForIndexPath:indexPath];
    if(configureBlock) {
        configureBlock([[STKUserStore store] currentUser], returnCell);
    }
    
    if([self nextItemsForIndexPath:indexPath]) {
        [returnCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [returnCell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return returnCell;
}



@end
