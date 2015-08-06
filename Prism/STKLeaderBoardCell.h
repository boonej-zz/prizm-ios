//
//  STKLeaderBoardCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAvatarView.h"

@interface STKLeaderBoardCell : UITableViewCell

@property (nonatomic, strong) UILabel *positionLabel;
@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *pointsLabel;

@property (nonatomic) long ranking;

@end
