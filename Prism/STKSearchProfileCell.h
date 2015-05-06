//
//  STKSearchProfileCell.h
//  Prism
//
//  Created by Joe Conway on 1/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKAvatarView.h"


@interface STKSearchProfileCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet STKAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelTrustButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIImageView *luminaryIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ambassadorIcon;
@property (strong, nonatomic) UIView *underlayView;

- (IBAction)toggleFollow:(id)sender;
- (IBAction)cancelTrust:(id)sender;
- (IBAction)sendMessage:(id)sender;

@end