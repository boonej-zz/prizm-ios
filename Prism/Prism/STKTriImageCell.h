//
//  STKTriImageCell.h
//  Prism
//
//  Created by Joe Conway on 1/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
@class STKResolvingImageView;

@interface STKTriImageCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKResolvingImageView *leftImageView;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *centerImageView;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *rightImageView;

- (IBAction)leftImageButtonTapped:(id)sender;
- (IBAction)centerImageButtonTapped:(id)sender;
- (IBAction)rightImageButtonTapped:(id)sender;

@end
