//
//  STKLuminariesCell.h
//  Prism
//
//  Created by Joe Conway on 4/15/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@class STKAvatarView;

@interface STKLuminariesCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKAvatarView *leftAvatarView;
@property (weak, nonatomic) IBOutlet STKAvatarView *centerAvatarView;
@property (weak, nonatomic) IBOutlet STKAvatarView *rightAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *leftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightTitleLabel;

@property (nonatomic, strong) NSArray *users;

- (IBAction)leftLuminaryTapped:(id)sender;
- (IBAction)centerLuminaryTapped:(id)sender;
- (IBAction)rightLuminaryTapped:(id)sender;

@end
