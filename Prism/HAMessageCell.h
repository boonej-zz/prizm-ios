//
//  HAMessageCell.h
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKMessage;
@class HAMessageCell;

@protocol HAMessageCellDelegate

- (void)likeButtonTapped:(HAMessageCell *)sender;

@end

@interface HAMessageCell : UITableViewCell

@property (nonatomic, strong) STKMessage *message;
@property (nonatomic, getter=isLiked) BOOL liked;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;

@end


