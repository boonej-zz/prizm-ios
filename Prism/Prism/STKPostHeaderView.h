//
//  STKPostHeaderView.h
//  Prism
//
//  Created by Joe Conway on 1/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKAvatarView;

@interface STKPostHeaderView : UIView

@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *posterLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UIImageView *postTypeView;
@property (nonatomic, strong) UIImageView *backdropFadeView;
@property (nonatomic, strong) UIControl *avatarButton;

@end
