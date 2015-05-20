//
//  HAMessageImageCell.h
//  Prizm
//
//  Created by Jonathan Boone on 5/19/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAvatarView.h"
#import "HAMessageCell.h"

@class STKMessage;

@interface HAMessageImageCell : UITableViewCell

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *creator;
@property (nonatomic, strong) UILabel *dateAgo;
@property (nonatomic, strong) UIImageView *postImage;
@property (nonatomic, strong) UILabel *likesCount;
@property (nonatomic, strong) STKMessage *message;
@property (nonatomic, getter=isLiked) BOOL liked;
@property (nonatomic, weak) id<HAMessageCellDelegate> delegate;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIImageView *clockImage;

@end
