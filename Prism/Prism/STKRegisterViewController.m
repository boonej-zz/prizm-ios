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

@interface STKRegisterViewController ()

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
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)connectWithTwitter:(id)sender
{
    [STKProcessingView present];
    [[STKUserStore store] fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
        if(!err) {
            if([accounts count] > 1) {
                [STKProcessingView dismiss];
                STKAccountChooserViewController *accChooser = [[STKAccountChooserViewController alloc] initWithAccounts:accounts];
                [[self navigationController] pushViewController:accChooser animated:YES];
            } else {
                ACAccount *acct = [accounts objectAtIndex:0];
                [[STKUserStore store] connectWithTwitterAccount:acct completion:^(STKUser *existingUser, STKProfileInformation *registrationData, NSError *err) {
                    [STKProcessingView dismiss];
                    if(!err) {
                        if(registrationData) {
                            STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] init];
                            [pvc setProfileInformation:registrationData];
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
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
    }];
}
- (IBAction)connectWithGoogle:(id)sender
{
    [STKProcessingView present];
    [[STKUserStore store] connectWithGoogle:^(STKUser *u, STKProfileInformation *googleData, NSError *err) {
        [STKProcessingView dismiss];
        
        if(!err) {
            if(u) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            } else {
                STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] init];
                [pvc setProfileInformation:googleData];
                [[self navigationController] pushViewController:pvc animated:YES];
            }
        } else {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
    }];
}

- (IBAction)connectWithFacebook:(id)sender
{
    [STKProcessingView present];
    [[STKUserStore store] connectWithFacebook:^(STKUser *u, STKProfileInformation *facebookData, NSError *err) {
        [STKProcessingView dismiss];
        if(!err) {
            if(u) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            } else {
                STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] init];
                [pvc setProfileInformation:facebookData];
                [[self navigationController] pushViewController:pvc animated:YES];
            }
        } else {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
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
    STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] init];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
