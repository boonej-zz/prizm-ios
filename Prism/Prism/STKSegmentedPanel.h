//
//  STKSegmentedPanel.h
//  Prism
//
//  Created by Joe Conway on 5/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKSegmentedPanel : UIControl

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) int selectedItem;

- (void)presentInView:(UIView *)view;

@end
