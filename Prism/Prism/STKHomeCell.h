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
#import "STKPostHeaderView.h"

@class STKPost;

@interface STKHomeCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet STKResolvingImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *hashTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet STKPostHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic) BOOL displayFullBleed;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftInset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightInset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topInset;

- (IBAction)toggleLike:(id)sender;
- (IBAction)showComments:(id)sender;
- (IBAction)addToPrism:(id)sender;
- (IBAction)sharePost:(id)sender;
- (IBAction)showLocation:(id)sender;
- (IBAction)imageTapped:(id)sender;

- (void)populateWithPost:(STKPost *)post;

@end
