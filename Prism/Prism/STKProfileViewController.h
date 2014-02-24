//
//  STKProfileViewController.h
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKUser;

@interface STKProfileViewController : UIViewController

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) STKUser *profile;

@end
