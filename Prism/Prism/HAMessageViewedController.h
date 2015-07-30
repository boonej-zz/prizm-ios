//
//  HAMessageViewedController.h
//  Prizm
//
//  Created by Jonathan Boone on 7/30/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKMessage;

@interface HAMessageViewedController : UIViewController

@property (nonatomic, strong) STKMessage *message;
@property (nonatomic, strong) NSArray *members;

@end
