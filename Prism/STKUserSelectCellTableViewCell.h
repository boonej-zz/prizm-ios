//
//  STKUserSelectCellTableViewCell.h
//  Prizm
//
//  Created by Jonathan Boone on 5/2/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAvatarView.h"
#import "HACellProtocol.h"


@interface STKUserSelectCellTableViewCell : UITableViewCell<HACellProtocol>

@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *toggle;

@end
