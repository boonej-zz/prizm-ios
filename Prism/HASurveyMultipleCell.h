//
//  HASurveyMultipleCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKQuestion;

@protocol HASurveyMultipleCellDelegate

- (void)multipleButtonTapped:(id)sender cell:(id)cell;

@end

@interface HASurveyMultipleCell : UITableViewCell

@property (nonatomic, strong) STKQuestion *question;
@property (nonatomic, strong) NSArray *valueButtons;
@property (nonatomic, weak) id delegate;

@end
