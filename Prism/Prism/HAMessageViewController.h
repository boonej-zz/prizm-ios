//
//  HAMessageViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 3/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKOrganization, STKGroup;

@interface HAMessageViewController : UIViewController

- (id)initWithOrganization:(STKOrganization *)organization;
- (id)initWithGroup:(STKGroup *)group organization:(STKOrganization *)organization;

@end
