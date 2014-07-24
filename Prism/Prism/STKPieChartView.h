//
//  STKPieChartView.h
//  Prism
//
//  Created by Joe Conway on 5/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKPieChartView : UIView
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSString *percentText;
@end
