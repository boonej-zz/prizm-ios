//
//  STKInsightArchiveCell.m
//  Prizm
//
//  Created by Jonathan Boone on 10/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInsightArchiveCell.h"
#import "STKAvatarView.h"
#import "STKInsightTarget.h"
#import "STKInsight.h"
#import "STKUser.h"

@interface STKInsightArchiveCell()

@property (nonatomic, weak) IBOutlet STKAvatarView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation STKInsightArchiveCell

- (void)awakeFromNib {
    // Initialization code
    [self.label setTextColor:[UIColor HATextColor]];
    [self.label setFont:STKFont(15)];
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    [self setAccessoryView:iv];
}

- (void)setInsightTarget:(STKInsightTarget *)insightTarget
{
    _insightTarget = insightTarget;
    self.label.text = insightTarget.insight.title;
    [self.avatarView setUrlString:insightTarget.insight.creator.profilePhotoPath];
}

- (void)setFrame:(CGRect)frame
{
//    frame.origin.x += 5;
//    frame.size.width -= 10;
    frame.origin.y += 1;
    frame.size.height -= 2;
    [super setFrame:frame];
}

@end
