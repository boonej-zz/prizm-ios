//
//  HAGroupInfoViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 5/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKGroup;
@class STKOrganization;

@interface HAGroupInfoViewController : UIViewController

- (id)initWithOrganization:(STKOrganization *)organization Group:(STKGroup *)group;

@end
