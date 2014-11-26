//
//  HAItemListViewController.h
//  Prizm
//
//  Created by Eric Kenny on 11/25/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAItemListViewController : UIViewController

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) void (^selectionBlock)(int index);

@end
