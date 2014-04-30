//
//  STKUserListViewController.h
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    STKUserListTypeFollow,
    STKUserListTypeTrust
} STKUserListType;

@interface STKUserListViewController : UIViewController

@property (nonatomic, strong) NSArray *users;
@property (nonatomic) STKUserListType type;

@end
