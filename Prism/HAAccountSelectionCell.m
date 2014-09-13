//
//  HAAccountSelectionCell.m
//  Prizm
//
//  Created by Jonathan Boone on 9/10/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAAccountSelectionCell.h"
#import "STKAvatarView.h"
#import "STKUser.h"

@interface HAAccountSelectionCell()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet STKAvatarView *avatarView;

@end

@implementation HAAccountSelectionCell

- (void)awakeFromNib
{
    // Initialization code
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
    [self.nameLabel setTextColor:STKTextColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAccount:(STKUser *)account
{
    _account = account;
    [self.nameLabel setText:self.account.name];
    [self.avatarView setUrlString:self.account.profilePhotoPath];
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.x += 5;
    frame.size.width -= 10;
    frame.origin.y += 2;
    frame.size.height -= 4;
    [super setFrame:frame];
}

@end
