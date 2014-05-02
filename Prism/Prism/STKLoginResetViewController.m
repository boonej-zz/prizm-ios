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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
