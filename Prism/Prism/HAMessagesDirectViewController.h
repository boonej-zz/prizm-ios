//
//  HAMessagesDirectViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 8/14/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKUser, STKOrganization;

@interface HAMessagesDirectViewController : UIViewController

@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) STKOrganization *organization;

@end
