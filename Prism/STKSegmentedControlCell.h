//
//  STKSegmentedControlCell.h
//  Prism
//
//  Created by Joe Conway on 4/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKSegmentedControl.h"

@interface STKSegmentedControlCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKSegmentedControl *control;
- (IBAction)controlChanged:(id)sender;

@end
