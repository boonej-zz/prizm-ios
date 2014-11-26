
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
#import "STKUser.h"
#import "STKUserStore.h"
#import "UIViewController+STKControllerItems.h"
@interface HAChangePasswordViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *currentPasswordField;
@property (nonatomic, weak) IBOutlet UITextField *updatedPasswordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmField;
@property (nonatomic, weak) IBOutlet UIView *instructionsView;

@end

@implementation HAChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundImage];
    
    [self.emailField setDelegate:self];
    [self.currentPasswordField setDelegate:self];
    [self.updatedPasswordField setDelegate:self];
    [self.confirmField setDelegate:self];
    self.user = [[STKUserStore store] currentUser];
    if (self.user.externalServiceType){
        [self.instructionsView setHidden:NO];
    }
        [self.emailField setText:self.user.email];
    [self.emailField setEnabled:NO];
    [self.currentPasswordField becomeFirstResponder];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(changePassword:)];
    [bbi setTitlePositionAdjustment:UIOffsetMake(-3, 0) forBarMetrics:UIBarMetricsDefault];
    [[self navigationItem] setRightBarButtonItem:bbi];
    [self addBlurViewWithHeight:64.f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // That's an awful lot of code for not much action.
    if ([[self currentPasswordField] isFirstResponder]) {
        
        if ([[[self currentPasswordField] text] length] > 0) {
            
            [[self updatedPasswordField] becomeFirstResponder];
            return NO;
        }
        else {
            [self emptyFieldsAlertView];
        }
        return NO;
    }
    else if ([[self updatedPasswordField] isFirstResponder]) {
        
        if ([[[self updatedPasswordField] text] length] > 0) {
            
            [[self confirmField] becomeFirstResponder];
            return NO;
        }
        else {
            [self emptyFieldsAlertView];
        }
        return NO;
    }
    else if ([[self confirmField] isFirstResponder]) {
        
        if ([[[self confirmField] text] length] > 0 &&
            [[[self updatedPasswordField] text] length] > 0 &&
            [[[self currentPasswordField] text] length] > 0) {
            
            if (![[[self confirmField] text] isEqualToString:[[self updatedPasswordField] text]]) {
                
                [self mismatchPasswordsAlertView];
                return NO;
            }
        }
        else {
            [self emptyFieldsAlertView];
            return NO;
        }
        if (![[[self confirmField] text] isEqualToString:[[self updatedPasswordField] text]]) {
            
            [self mismatchPasswordsAlertView];
            return NO;
        }
    }
    [self updatePassword];
    return YES;
}

- (IBAction)changePassword:(id)sender
{
    if(!([[[self emailField] text] length] > 0
         && [[[self updatedPasswordField] text] length] > 0
         && [[[self confirmField] text] length] > 0)) {
        
        [self emptyFieldsAlertView];
        return;
    }
    
    if(![[[self confirmField] text] isEqualToString:[[self updatedPasswordField] text]]) {
        
        [self mismatchPasswordsAlertView];
        return;
    }
    [self updatePassword];

}

- (void)updatePassword
{
    [STKProcessingView present];
    
    [[STKUserStore store] changePasswordForEmail:[[self emailField] text]
                                 currentPassword:[[self currentPasswordField] text]
                                     newPassword:[[self updatedPasswordField] text]
                                      completion:^(NSError *err) {
        
                                          [STKProcessingView dismiss];
                                          if (err) {
                                              UIAlertView *av = [STKErrorStore alertViewForError:err delegate:nil];
                                              [av show];
                                          }
                                          else {
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
                                                 message:NSLocalizedString(@"Your password has been successfully changed.", @"change password successful message")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                       otherButtonTitles:nil];
    [av show];
}


@end
