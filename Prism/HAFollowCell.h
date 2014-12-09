//
//  HAFollowCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKResolvingImageView.h"

@class  STKUser;

@interface HAFollowCell : STKTableViewCell

@property (nonatomic, strong) STKUser *profile;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, weak) IBOutlet STKResolvingImageView *leftImage;
@property (nonatomic, weak) IBOutlet STKResolvingImageView *centerImage;
@property (nonatomic, weak) IBOutlet STKResolvingImageView *rightImage;
- (void)setFollowed;
@end
