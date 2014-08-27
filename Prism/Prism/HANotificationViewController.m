//
//  HANotificationViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/25/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HANotificationViewController.h"

@interface HANotificationViewController ()

@property (nonatomic, readonly) BOOL hasTrustNotifications;
@property (nonatomic, readonly) BOOL hasActivityNotifications;

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UIImageView *rightImageView;

@end

@implementation HANotificationViewController

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

- (void)setActivityNotifications:(BOOL)hasActivityNotifications andTrustNotitifications:(BOOL)hasTrustNotifications
{
    _hasActivityNotifications = hasActivityNotifications;
    _hasTrustNotifications = hasTrustNotifications;
    if (self.hasActivityNotifications) {
        [self.leftImageView setImage:[UIImage imageNamed:@"like_notification"]];
        if (self.hasTrustNotifications) {
            [self.rightImageView setImage:[UIImage imageNamed:@"user_notification"]];
        }
    } else if (self.hasTrustNotifications) {
        [self.leftImageView setImage:[UIImage imageNamed:@"user_notification"]];
        [self.rightImageView setImage:nil];
    } else {
        [self.leftImageView setImage:nil];
        [self.rightImageView setImage:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
