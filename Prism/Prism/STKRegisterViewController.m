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
    
    [[STKUserStore store] fetchTwitterAccount:^(STKUser *u, STKProfileInformation *twitterData, NSError *err) {
        [STKProcessingView dismiss];
        
        if(!err) {
            if(u) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            } else {
                STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] init];
                [pvc setProfileInformation:twitterData];
                [[self navigationController] pushViewController:pvc animated:YES];
            }
        } else {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
    }];
}
- (IBAction)connectWithGoogle:(id)sender
{
    [STKProcessingView present];
    [[STKUserStore store] fetchGoogleAccount:^(STKUser *u, STKProfileInformation *googleData, NSError *err) {
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
    [[STKUserStore store] fetchFacebookAccount:^(STKUser *u, STKProfileInformation *facebookData, NSError *err) {
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
