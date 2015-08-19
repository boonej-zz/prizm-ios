//
//  HAMessagesViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 8/14/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKUser, STKOrganization, STKGroup;

@interface HAMessagesViewController : UIViewController

- (instancetype)initWithOrganization:(STKOrganization *)organization group:(STKGroup *)group;
- (instancetype)initWithOrganization:(STKOrganization *)organization group:(STKGroup *)group user:(STKUser *)user;

@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, strong) STKGroup *group;
@property (nonatomic, strong) STKUser *sender;
@property (nonatomic) BOOL userIsLeader;
@property (nonatomic) BOOL userIsOwner;

@end
