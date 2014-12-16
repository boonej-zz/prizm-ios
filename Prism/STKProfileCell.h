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
#import "STKButtonRow.h"

typedef enum {
    STKProfileCellTypeUser,
    STKProfileCellTypeInstitution
} STKProfileCellType;


@interface STKProfileCell : STKTableViewCell

// name, location, blurb, (founded, mascot, pop), luminaries

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet STKAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *luminaryIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ambassadorIcon;

@property (weak, nonatomic) IBOutlet UILabel *blurbLabel;
@property (weak, nonatomic) IBOutlet UILabel *luminaryInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;

@property (weak, nonatomic) IBOutlet STKAvatarView *leftAvatarView;
@property (weak, nonatomic) IBOutlet STKAvatarView *centerAvatarView;
@property (weak, nonatomic) IBOutlet STKAvatarView *rightAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *leftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightTitleLabel;

@property (nonatomic, strong) NSArray *luminaries;

@property (nonatomic) STKProfileCellType type;

@end
