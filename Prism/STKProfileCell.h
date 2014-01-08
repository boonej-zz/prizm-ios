//
//  STKProfileCell.h
//  Prism
//
//  Created by Joe Conway on 12/27/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKResolvingImageView.h"

@class STKCountView;

@interface STKProfileCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKCountView *countView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *avatarView;

@end
