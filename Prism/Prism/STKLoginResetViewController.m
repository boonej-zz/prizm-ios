//
//  STKLoginResetViewController.m
//  Prism
//
//  Created by DJ HAYDEN on 5/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLoginResetViewController.h"
#import "STKUserStore.h"
#import "STKProcessingView.h"
#import "STKLoginViewController.h"
#import "STKErrorStore.h"

@interface STKLoginResetViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmField;

@end

@implementation STKLoginResetViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self emailField] becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(!([[[self emailField] text] length] > 0
       && [[[self passwordField] text] length] > 0
       && [[[self confirmField] text] length] > 0))
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Enter all fields" message:@"Enter all fields to reset your password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return NO;

    }
    
    if(![[[self confirmField] text] isEqualToString:[[self passwordField] text]]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Passwords do no match" message:@"Ensure the password and confirm password field match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return NO;
    }
    
    [STKProcessingView present];
    
    [[STKUserStore store] resetPasswordForEmail:[[self emailField] text]
                                       password:[[self passwordField] text]
                                     completion:^(NSError *err) {
                                         [STKProcessingView dismiss];
                                         if(err) {
                                             UIAlertView *av = [STKErrorStore alertViewForError:err delegate:nil];
                                             [av show];
                                         } else {
                                             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Confirm Reset" message:@"An e-mail will be sent to you. Click the link on that e-mail to confirm this change." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                             [av show];
                                             [[self navigationController] popViewControllerAnimated:YES];
                                         }
                                     }];
    
    return NO;
}

@end