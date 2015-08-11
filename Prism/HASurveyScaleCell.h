//
//  HASurveyScaleCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HASurveyScaleCellDelegate

- (void)scaleButtonTapped:(id)sender cell:(id)cell;

@end

@class STKQuestion;

@interface HASurveyScaleCell : UITableViewCell

@property (nonatomic, strong) STKQuestion *question;
@property (nonatomic, strong) NSArray *valueButtons;
@property (nonatomic, weak) id delegate;

@end
