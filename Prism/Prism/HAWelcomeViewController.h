//
//  HAWelcomeViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 12/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKOrganization.h"

@interface HAWelcomeViewController : UIViewController

@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, getter=isIntroFlow) BOOL introFlow;

@end
