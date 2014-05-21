//
//  STKItemListViewController.h
//  Prism
//
//  Created by Joe Conway on 5/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKItemListViewController : UIViewController
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) void (^selectionBlock)(int index);
@end
