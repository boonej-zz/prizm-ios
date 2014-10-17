//
//  HAFollowViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 8/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKMenuController.h"

@interface HAFollowViewController : UIViewController

@property (nonatomic, weak) STKMenuController *menuController;
@property (nonatomic, getter=isStandalone) BOOL standalone;

@end
