//
//  HAInsightsViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 10/1/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKInsightTarget;

@interface HAInsightsViewController : UIViewController

@property (nonatomic, strong) STKInsightTarget *insightTarget;
@property (nonatomic, getter=isModal) BOOL modal;
@property (nonatomic, getter=isArchived) BOOL archived;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@end
