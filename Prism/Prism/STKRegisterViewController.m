//
//  STKRegisterViewController.m
//  Prism
//
//  Created by Joe Conway on 11/25/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKRegisterViewController.h"
#import "STKUserStore.h"
#import "STKLoginViewController.h"
#import "STKCreateProfileViewController.h"
#import "STKProcessingView.h"
#import "STKErrorStore.h"
#import "STKAccountChooserViewController.h"
#import "STKIntroViewController.h"
#import "Mixpanel.h"

@import Accounts;
@import Social;

@interface STKRegisterViewController () <STKAccountChooserDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapConstraint;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic) BOOL attemptingGoogleLogin;

@end

@implementation STKRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self presentIntroIfNeccessary];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[Mixpanel sharedInstance] track:@"Registration" properties:@{@"status": @"exiting controller"}];
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mixpanel track:@"Registration Begin"];
    float screenHeightDelta = 568.0 - [[UIScreen mainScreen] bounds].size.height;
    if(fabs(screenHeightDelta) > 0)
        [[self gapConstraint] setConstant:10];
    
}

- (void)accountChooser:(STKAccountChooserViewController *)chooser
      didChooseAccount:(ACAccount *)account
{
    [STKProcessingView present];
    [self.mixpanel track:@"Selected Twitter - Login"];
    [[STKUserStore store] connectWithTwitterAccount:account completion:^(STKUser *existingUser, STKUser *registrationData, NSError *err) {
        [STKProcessingView dismiss];
        if(!err) {
            if(registrationData) {
                STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] initWithProfileForCreating:registrationData];
                [[self navigationController] pushViewController:pvc animated:YES];
            } else if(existingUser) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
    }];
}

- (IBAction)connectWithTwitter:(id)sender
{
    [self.mixpanel track:@"Social Registration" properties:@{@"status":@"Social Connect", @"provider": @"twitter"}];
    [STKProcessingView present];
    [[STKUserStore store] fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
        if(!err) {
            if([accounts count] > 1) {
                [STKProcessingView dismiss];
                STKAccountChooserViewController *accChooser = [[STKAccountChooserViewController alloc] initWithAccounts:accounts];
                [accChooser setDelegate:self];
                [[self navigationController] pushViewController:accChooser animated:YES];
            } else {
                ACAccount *acct = [accounts objectAtIndex:0];
                [[STKUserStore store] connectWithTwitterAccount:acct completion:^(STKUser *existingUser, STKUser *registrationData, NSError *err) {
                    [STKProcessingView dismiss];
                    if(!err) {
                        if(registrationData) {
                            STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] initWithProfileForCreating:registrationData];
                            [[self navigationController] pushViewController:pvc animated:YES];
                        } else if(existingUser) {
                            [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                        }
                    } else {
                        [[STKErrorStore alertViewForError:err delegate:nil] show];
                    }
                }];
            }
        } else {
            [STKProcessingView dismiss];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }];
        }
    }];
}
- (IBAction)connectWithGoogle:(id)sender
{
    [STKProcessingView present];
    [self setAttemptingGoogleLogin:YES];
    [[STKUserStore store] connectWithGoogle:^(STKUser *u, STKUser *googleData, NSError *err) {
        [STKProcessingView dismiss];
        [self setAttemptingGoogleLogin:NO];
        
        if(!err) {
            if(u) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            } else {
                STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] initWithProfileForCreating:googleData];
                [[self navigationController] pushViewController:pvc animated:YES];
            }
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }];
        }
    } processing:^{
        [STKProcessingView present];
    }];
}

- (IBAction)connectWithFacebook:(id)sender
{
    [self.mixpanel track:@"Social Registration" properties:@{@"status":@"Social Connect", @"provider": @"facebook"}];
    [STKProcessingView present];
    [[STKUserStore store] connectWithFacebook:^(STKUser *u, STKUser *facebookData, NSError *err) {
        [STKProcessingView dismiss];
        if(!err) {
            if(u) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            } else {
                STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] initWithProfileForCreating:facebookData];
                [[self navigationController] pushViewController:pvc animated:YES];
            }
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }];
        }
    }];
}
- (IBAction)loginAccount:(id)sender
{
    STKLoginViewController *lvc = [[STKLoginViewController alloc] init];
    [[self navigationController] pushViewController:lvc animated:YES];
}
- (IBAction)registerAccount:(id)sender
{
    [self.mixpanel track:@"Standard Registration"];
    STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] initWithProfileForCreating:nil];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)presentIntroIfNeccessary
{
    BOOL introComplete = [[NSUserDefaults standardUserDefaults] boolForKey:STKIntroCompletedKey];
    if (!introComplete) {
        STKIntroViewController *ivc = [[STKIntroViewController alloc] initWithNibName:@"STKIntroViewController" bundle:nil];
        [self presentViewController:ivc animated:NO completion:nil];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)note
{
    if ([self attemptingGoogleLogin] == YES) {
        [STKProcessingView dismiss];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
     
@end
