//
//  STKActivityCell.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@interface STKActivityCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *recentIndicatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageReferenceView;

@end
