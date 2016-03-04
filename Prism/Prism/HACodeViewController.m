//
//  HACodeViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 3/2/16.
//  Copyright © 2016 Higher Altitude. All rights reserved.
//

#import "HACodeViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKCreateProfileViewController.h"
#import "STKUser.h"

@interface HACodeViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSString * mProgamCode;
@property (strong, nonatomic) STKUser * profile;

@end

@implementation HACodeViewController

- (id)initWithProfile:(STKUser *)profile
{
    self = [super init];
    
    if (self) {
        self.profile = profile;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addBackgroundImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.profile.programCode = textField.text;
    [textField resignFirstResponder];
    [self beginProfile];
    return false;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.profile.programCode = textField.text;
}

- (IBAction)nextButtonTapped:(id)sender
{
    [self beginProfile];
}

- (IBAction)noCodeTapped:(id)sender
{
    self.profile.programCode = nil;
    [self beginProfile];
}

- (void)beginProfile
{
    
    STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] initWithProfileForCreating:self.profile];
    [self.navigationController pushViewController:pvc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
