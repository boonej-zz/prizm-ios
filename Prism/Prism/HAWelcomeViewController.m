//
//  HAWelcomeViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 12/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAWelcomeViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKResolvingImageView.h"
#import "HAFollowViewController.h"
#import "STKAvatarView.h"

@interface HAWelcomeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *greeting;
//@property (nonatomic, weak) IBOutlet STKResolvingImageView *orgLogo;
@property (nonatomic, weak) IBOutlet UILabel *orgText;
@property (nonatomic, weak) IBOutlet STKResolvingImageView *orgImage;
@property (nonatomic, weak) IBOutlet UIView *navView;
@property (nonatomic, weak) IBOutlet UIView *shadedView;
@property (nonatomic, weak) IBOutlet STKAvatarView *avatarView;

@end

@implementation HAWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addBackgroundImage];
    [self.greeting setTextColor:[UIColor HATextColor]];
    [self.greeting setFont:STKFont(22)];
    [self.orgText setTextColor:[UIColor HATextColor]];
    [self.orgText setFont:STKFont(20)];
    [self.navView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.shadedView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *text = [NSString stringWithFormat:@"%@ on Prizm", self.organization.name];
    [self.orgText setText:text];
    [self.orgImage setUrlString:self.organization.welcomeImageURL];
//    [self.orgLogo setUrlString:self.organization.logoURL];
    [self.avatarView setUrlString:self.organization.logoURL];
}


- (IBAction)doneButtonTapped:(id)sender
{
    if (self.navigationController) {
        if ([self isIntroFlow]){
            HAFollowViewController *fvc = [[HAFollowViewController alloc] init];
            [fvc setStandalone:YES];
            [self.navigationController pushViewController:fvc animated:YES];
        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
