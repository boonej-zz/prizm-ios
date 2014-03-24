//
//  STKCommentCell.h
//  Prism
//
//  Created by Joe Conway on 1/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@class STKAvatarView;

@interface STKCommentCell : STKTableViewCell
@property (weak, nonatomic) IBOutlet STKAvatarView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *clockImageView;
@property (weak, nonatomic) IBOutlet UIControl *likeButton;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
- (IBAction)avatarTapped:(id)sender;
- (IBAction)showLikes:(id)sender;

@end
