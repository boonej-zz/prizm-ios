//
//  STKTextInputViewController.h
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKTextInputViewController : UIViewController

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) void (^completion)(NSString *text);

@end
