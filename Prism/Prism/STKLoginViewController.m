//
//  STKLoginViewController.m
//  Prism
//
//  Created by Joe Conway on 12/5/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKLoginViewController.h"
#import "STKUserStore.h"
#import "STKProcessingView.h"

@interface STKLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)forgotPassword:(id)sender;

@end

@implementation STKLoginViewController

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

    NSDictionary *attrs = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5],
                            NSUnderlineStyleAttributeName: @(1),
                            NSFontAttributeName : [UIFont systemFontOfSize:12]};
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Forgot Password?"
                                                              attributes:attrs];
    [[self forgotPasswordButton] setAttributedTitle:str
                                           forState:UIControlStateNormal];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([[[self emailField] text] length] > 0 && [[[self passwordField] text] length] > 0) {
        [STKProcessingView present];
        [[STKUserStore store] loginWithEmail:[[self emailField] text]
                                    password:[[self passwordField] text]
                                  completion:^(STKUser *u, NSError *err) {
                                      [STKProcessingView dismiss];
                                      if(!err) {
                                          [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                      } else {
                                          [[STKErrorStore alertViewForError:err delegate:nil] show];
                                      }
                                  }];
    } else if([[[self emailField] text] length] == 0) {
        [[self emailField] becomeFirstResponder];
    } else {
        [[self passwordField] becomeFirstResponder];
    }
    
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self emailField] becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgotPassword:(id)sender
{

}

@end
