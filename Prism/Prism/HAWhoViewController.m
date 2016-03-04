//
//  HAWhoViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 3/2/16.
//  Copyright © 2016 Higher Altitude. All rights reserved.
//

#import "HAWhoViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "HACodeViewController.h"
#import "STKCreateProfileViewController.h"
#import "STKUser.h"
#import "STKUserStore.h"

@interface HAWhoViewController ()

@property (nonatomic, strong) STKUser *profile;


@end

@implementation HAWhoViewController

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
    if (!self.profile) {
        self.profile = [NSEntityDescription
                        insertNewObjectForEntityForName:@"STKUser"
                        inManagedObjectContext:[[STKUserStore store] context]];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)individualTapped:(id)sender {
    self.profile.type = STKUserTypePersonal;
    HACodeViewController *cvc = [[HACodeViewController alloc] init];
    [self.navigationController pushViewController:cvc animated:YES];
}

- (IBAction)organizationTapped:(id)sender {
    self.profile.type = STKUserTypeInstitution;
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
