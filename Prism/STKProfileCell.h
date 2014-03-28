//
//  STKProfileCell.h
//  Prism
//
//  Created by Joe Conway on 12/27/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKResolvingImageView.h"
#import "STKAvatarView.h"


@interface STKProfileCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet STKAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;

@property (nonatomic) BOOL showPrismImageForToggleButton;

- (IBAction)toggleInformation:(id)sender;

@end
