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

@import Accounts;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)connectWithTwitter:(id)sender {
}
- (IBAction)connectWithGoogle:(id)sender {
}

- (IBAction)connectWithFacebook:(id)sender
{
    [[STKUserStore store] fetchAccountsForDevice:^(NSArray *accounts, NSError *err) {
        if(!err) {
            if([accounts count] == 1) {
                ACAccount *acct = [accounts objectAtIndex:0];
                ACAccountCredential *creds = [acct credential];
                NSLog(@"%@", acct);
                NSLog(@"%@", [creds oauthToken]);
            }
        } else {
            NSLog(@"%@", err);
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
