//
//  STKHomeCell.h
//  Prism
//
//  Created by Joe Conway on 11/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKTableViewCell.h"
#import "STKResolvingImageView.h"

@interface STKHomeCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *iconImageView;
@property (weak, nonatomic) IBOutlet STKResolvingImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *originatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *hashTagLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backdropFadeView;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

- (IBAction)toggleLike:(id)sender;
- (IBAction)showComments:(id)sender;
- (IBAction)addToPrism:(id)sender;
- (IBAction)sharePost:(id)sender;
- (IBAction)pinPost:(id)sender;

@end
