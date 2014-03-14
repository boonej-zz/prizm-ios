//
//  STKCreateProfileViewController.h
//  Prism
//
//  Created by Joe Conway on 12/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Accounts;
@class STKUser;

@interface STKCreateProfileViewController : UIViewController

- (id)initWithProfileForEditing:(STKUser *)user;
- (id)initWithProfileForCreating:(STKUser *)user;


@end
