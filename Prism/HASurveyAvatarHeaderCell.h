//
//  HASurveyAvatarHeaderCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAvatarView.h"

@interface HASurveyAvatarHeaderCell : UITableViewCell

@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;

@end
