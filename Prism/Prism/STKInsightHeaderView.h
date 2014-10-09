//
//  STKInsightHeaderView.h
//  Prizm
//
//  Created by Jonathan Boone on 10/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKAvatarView;
@class STKUser;

@protocol STKInsightHeaderProtocol

- (void)dislikeButtonTapped:(id)sender;
- (void)likeButtonTapped:(id)sender;
- (void)avatarTapped:(STKUser *)user;

@end

@interface STKInsightHeaderView : UIView

@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *posterLabel;

@property (nonatomic, strong) UIImageView *backdropFadeView;
@property (nonatomic, strong) UIControl *avatarButton;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *dislikeButton;

@property (nonatomic, weak) id<STKInsightHeaderProtocol> delegate;

@end


