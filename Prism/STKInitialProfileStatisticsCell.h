//
//  STKInitialProfileStatisticsCell.h
//  Prism
//
//  Created by Joe Conway on 1/8/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@class STKCountView;

@interface STKInitialProfileStatisticsCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKCountView *circleView;

- (IBAction)editProfile:(id)sender;

@end
