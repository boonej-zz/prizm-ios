//
//  HAMessageCell.m
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessageCell.h"
#import "STKAvatarView.h"
#import "STKMessage.h"
#import "STKUser.h"
#import "STKRelativeDateConverter.h"

@interface HAMessageCell()

@property (nonatomic, weak) IBOutlet STKAvatarView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *creator;
@property (nonatomic, weak) IBOutlet UILabel *dateAgo;
@property (nonatomic, weak) IBOutlet UITextView *postText;
@property (nonatomic, weak) IBOutlet UILabel *likesCount;


- (IBAction)likeButtonTapped:(id)sender;

@end

@implementation HAMessageCell


- (void)awakeFromNib {
    // Initialization code
    [self.creator setFont:STKFont(18.0f)];
    [self.dateAgo setFont:STKFont(9.0f)];
    [self.postText setFont:STKFont(14.f)];
    [self.creator setTextColor:[UIColor HATextColor]];
    
    [self.dateAgo setTextColor:[UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:1]];
    [self setBackgroundColor:[UIColor clearColor]];
   
    [self.postText setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(STKMessage *)message
{
    _message = message;
    [self.avatarView setUrlString:message.creator.profilePhotoPath];
    [self.postText setText:message.text];
    [self.creator setText:message.creator.name];
    [self.postText setTextColor:[UIColor HATextColor]];
    [self.dateAgo setText:[NSString stringWithFormat:@"%@", [STKRelativeDateConverter relativeDateStringFromDate:message.createDate]]];
    if ([message.likesCount integerValue] > 0) {
        [self.likesCount setText:[NSString stringWithFormat:@"%@", message.likesCount]];
    } else {
        [self.likesCount setText:@""];
    }
}

- (void)setLiked:(BOOL)liked
{
    _liked = liked;
    if (liked) {
        [self.likeButton setImage:[UIImage imageNamed:@"action_heart_like"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"action_heart"] forState:UIControlStateNormal];
    }
    [self.likeButton setEnabled:YES];
}

- (IBAction)likeButtonTapped:(id)sender
{
    [self.likeButton setEnabled:NO];
    if (self.delegate) {
        [self.delegate likeButtonTapped:self];
    }
}

@end
