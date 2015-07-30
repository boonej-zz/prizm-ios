//
//  HAMessageCell.h
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKMessage;
@class HAMessageCell;
@class STKAvatarView;

@protocol HAMessageCellDelegate

- (void)likeButtonTapped:(HAMessageCell *)sender;
- (void)previewImageTapped:(NSURL *)url;
- (void)videoImageTapped:(NSURL *)url;
- (void)messageImageTapped:(STKMessage *)message;
- (void)viewedButtonTapped:(HAMessageCell *)sender;

@end

@interface HAMessageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet STKAvatarView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *creator;
@property (nonatomic, weak) IBOutlet UILabel *dateAgo;
@property (nonatomic, weak) IBOutlet UITextView *postText;
@property (nonatomic, weak) IBOutlet UILabel *likesCount;
@property (nonatomic, strong) STKMessage *message;
@property (nonatomic, getter=isLiked) BOOL liked;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *viewedButton;
@property (nonatomic, weak) IBOutlet UILabel *viewedLabel;

@end


