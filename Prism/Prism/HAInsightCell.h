//
//  HAInsightCell.h
//  Prizm
//
//  Created by Jonathan Boone on 10/1/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKTableViewCell.h"

@class STKInsight;
@class STKInsightTarget;
@class HAInsightCell;
@class STKResolvingImageView;
@class STKUser;

@protocol STKInsightCellDelegate

- (void)likeButtonTapped:(STKInsightTarget *)it;
- (void)dislikeButtonTapped:(STKInsightTarget *)it;
- (void)shareInsight:(STKInsight *)insight;
- (void)insightImageTapped:(HAInsightCell *)cell;
- (void)avatarImageTapped:(STKUser *)user;

@end

@class STKInsightTarget;

@interface HAInsightCell : STKTableViewCell

@property (nonatomic, weak) IBOutlet STKResolvingImageView *postImageView;
@property (nonatomic, strong) STKInsightTarget *insightTarget;
@property (nonatomic, getter=isFullBleed) BOOL fullBleed;
@property (nonatomic, getter=isArchived) BOOL archived;
@property (nonatomic, weak) id<STKInsightCellDelegate> delegate;

@end
