//
//  STKUserPostListViewController.h
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKTrust.h"

@class STKUser;


@interface STKUserPostListViewController : UIViewController

- (id)initWithUser:(STKUser *)user;
- (id)initWithTrust:(STKTrust *)t;

@property (nonatomic) STKTrustPostType trustType;
@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) STKTrust *trust;
@property (nonatomic) BOOL showsFilterBar;

@end
