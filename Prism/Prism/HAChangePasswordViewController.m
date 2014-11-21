
//
//  HAChangePasswordViewController.m
//  Prizm
//
//  Created by Eric Kenny on 11/21/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAChangePasswordViewController.h"
#import "STKUserStore.h"
#import "STKProcessingView.h"
#import "STKLoginViewController.h"
#import "STKErrorStore.h"

@interface HAChangePasswordViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmField;

@end

@implementation HAChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *backgroundImage = [UIImage imageNamed:@"img_background"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    
    [self.emailField setDelegate:self];
    [self.passwordField setDelegate:self];
    [self.confirmField setDelegate:self];
    
    [self.emailField setText:self.userEmail];
    [self.emailField setEnabled:NO];
    [self.passwordField becomeFirstResponder];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(changePassword:)];
    [bbi setTitlePositionAdjustment:UIOffsetMake(-3, 0) forBarMetrics:UIBarMetricsDefault];
    [[self navigationItem] setRightBarButtonItem:bbi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([[self passwordField] isFirstResponder]) {
        if ([[[self passwordField] text] length] > 0) {
            [[self confirmField] becomeFirstResponder];
            return NO;
        }
        else {
            [self emptyFieldsAlertView];
        }
        return NO;
    }
    else if ([[self confirmField] isFirstResponder]) {
        if (![[[self passwordField] text] length] > 0 && [[[self confirmField] text] length] > 0) {
            [self emptyFieldsAlertView];
            return NO;
        }
    }
    else if (![[[self confirmField] text] isEqualToString:[[self passwordField] text]]) {
        [self mismatchPasswordsAlertView];
        return NO;
    }
    [self resetPassword];
    return YES;
}

- (IBAction)changePassword:(id)sender
{
    if(!([[[self emailField] text] length] > 0
         && [[[self passwordField] text] length] > 0
         && [[[self confirmField] text] length] > 0)) {
        
        [self emptyFieldsAlertView];
        return;
    }
    
    if(![[[self confirmField] text] isEqualToString:[[self passwordField] text]]) {
        [self mismatchPasswordsAlertView];
        return;
    }
    [self resetPassword];

}

- (void)resetPassword
{
    [STKProcessingView present];
    
    [[STKUserStore store] resetPasswordForEmail:[[self emailField] text]
                                       password:[[self passwordField] text]
                                     completion:^(NSError *err) {
                                         [STKProcessingView dismiss];
                                         if(err) {
                                             UIAlertView *av = [STKErrorStore alertViewForError:err delegate:nil];
                                             [av show];
                                         } else {
                                             [self successfulChangeAlertView];
                                             [[self navigationController] popViewControllerAnimated:YES];
                                         }
                                     }];
}

- (void)emptyFieldsAlertView
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter All Fields", @"enter all fields title")
                                                 message:NSLocalizedString(@"Please enter all fields to reset your password.", @"enter all fields message")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                       otherButtonTitles:nil];
    [av show];
}

- (void)mismatchPasswordsAlertView
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Passwords do no match", @"reset login passwords do not match title")
                                                 message:NSLocalizedString(@"Oops. Ensure the ‘password’ and ‘confirm password’ fields match", @"reset login passwords do not match message")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                       otherButtonTitles:nil];
    [av show];
}

- (void)successfulChangeAlertView
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm Reset", @"confirm reset login")
                                                 message:NSLocalizedString(@"An e-mail will be sent to you. Click the link on that e-mail to confirm this change.", @"confirm reset message")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                       otherButtonTitles:nil];
    [av show];
}


@end
