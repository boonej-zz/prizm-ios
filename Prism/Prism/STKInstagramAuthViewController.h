//
//  STKInstagramAuthViewController.h
//  Prism
//
//  Created by Joe Conway on 4/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKInstagramAuthViewController : UIViewController

@property (nonatomic, strong) void (^tokenFound)(NSString *token);

@end
