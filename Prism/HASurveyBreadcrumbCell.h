//
//  HASurveyBreadcrumbCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKSurvey;

@interface HASurveyBreadcrumbCell : UITableViewCell

@property (nonatomic, strong) STKSurvey *survey;
@property (nonatomic) NSInteger questionNumber;

@end
