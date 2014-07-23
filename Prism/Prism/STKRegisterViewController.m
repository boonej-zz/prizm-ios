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

@import Accounts;
@import Social;

@interface STKRegisterViewController () <STKAccountChooserDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapConstraint;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    float screenHeightDelta = 568.0 - [[UIScreen mainScreen] bounds].size.height;
    if(fabs(screenHeightDelta) > 0)
        [[self gapConstraint] setConstant:10];
    
}

- (void)accountChooser:(STKAccountChooserViewController *)chooser
      didChooseAccount:(ACAccount *)account
{
    [STKProcessingView present];
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
    [[STKUserStore store] connectWithGoogle:^(STKUser *u, STKUser *googleData, NSError *err) {
        [STKProcessingView dismiss];
        
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
    STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] initWithProfileForCreating:nil];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
