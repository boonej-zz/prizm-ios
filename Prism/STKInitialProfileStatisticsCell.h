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
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *trustButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *accoladesButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

- (IBAction)editProfile:(id)sender;
- (IBAction)requestTrust:(id)sender;
- (IBAction)follow:(id)sender;
- (IBAction)showAccolades:(id)sender;
- (IBAction)sendMessage:(id)sender;

@end
