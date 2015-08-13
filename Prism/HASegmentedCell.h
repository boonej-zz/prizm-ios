//
//  HASegmentedCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/13/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HASegmentedCell : UITableViewCell

- (id)initWithItems:(NSArray *)items;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end
