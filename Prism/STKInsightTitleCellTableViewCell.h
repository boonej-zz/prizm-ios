//
//  STKInsightTitleCellTableViewCell.h
//  Prizm
//
//  Created by Jonathan Boone on 10/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKTableViewCell.h"
@class STKInsightTarget;
@class STKInsight;

@protocol STKInsightTitleCellDelegate

- (void)shareInsight:(STKInsight *)insight;
- (void)titleControlTapped:(STKInsightTarget *)it;

@end

@interface STKInsightTitleCellTableViewCell : STKTableViewCell

@property (nonatomic, strong) STKInsightTarget *insightTarget;
@property (nonatomic, weak) id delegate;
@property (nonatomic, getter=isFullBleed) BOOL fullBleed;
@property (nonatomic, weak) IBOutlet UIControl *titleOverlay;



@end
