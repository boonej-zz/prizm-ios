//
//  HAAvatarImageCell.h
//  Prizm
//
//  Created by Jonathan Boone on 4/27/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAvatarView.h"

@interface HAAvatarImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet STKAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end
