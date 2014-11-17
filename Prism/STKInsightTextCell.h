//
//  STKInsightTextCell.h
//  Prizm
//
//  Created by Jonathan Boone on 10/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKInsightTarget;

@interface STKInsightTextCell : UITableViewCell

@property (nonatomic, strong) STKInsightTarget *insightTarget;
@property (nonatomic, weak) IBOutlet UITextView *textView;

@end
