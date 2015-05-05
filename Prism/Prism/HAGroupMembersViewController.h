//
//  HAGroupMembersViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 5/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKGroup;
@class STKOrganization;

@interface HAGroupMembersViewController : UIViewController

@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, strong) STKGroup *group;

@end
