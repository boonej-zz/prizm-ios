//
//  STKGraphView.h
//  Prism
//
//  Created by Joe Conway on 5/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKGraphView : UIView

@property (nonatomic, strong) NSArray *yLabels;
@property (nonatomic, strong) NSArray *xLabels;

// @{@"y" : [y], @"color" : c}
// count of [y] must be equal to xLabel count
@property (nonatomic, strong) NSArray *values;

@end
