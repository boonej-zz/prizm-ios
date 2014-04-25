//
//  STKRequestCell.h
//  Prism
//
//  Created by Joe Conway on 1/29/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKAvatarView.h"

@class STKTrust;

@interface STKRequestCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKAvatarView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIImageView *unreadIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *acceptIndicator;

- (void)populateWithTrust:(STKTrust *)t;
- (IBAction)acceptRequest:(id)sender;
- (IBAction)rejectRequest:(id)sender;
- (IBAction)profileTapped:(id)sender;

@end
