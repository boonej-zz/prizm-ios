//
//  STKRequestCell.h
//  Prism
//
//  Created by Joe Conway on 1/29/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKResolvingImageView.h"

@interface STKRequestCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKResolvingImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

- (IBAction)acceptRequest:(id)sender;
- (IBAction)rejectRequest:(id)sender;

@end
