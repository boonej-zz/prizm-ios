//
//  HASurveyRankingCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HASurveyRankingCellProtocol

- (void)surveyCountTapped:(id)sender;

@end

@interface HASurveyRankingCell : UITableViewCell

@property (nonatomic, strong) UILabel *rankingLabel;
@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, strong) UILabel *surveysLabel;
@property (nonatomic, weak) id delegate;

@end
