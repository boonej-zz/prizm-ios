//
//  HAPlainAvatarCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/16/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAvatarView.h"


@interface HAPlainAvatarCell : UITableViewCell

@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *countView;
@property (nonatomic, strong) UILabel *countLabel;

@end
