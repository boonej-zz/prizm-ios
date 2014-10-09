//
//  STKInsightTitleCellTableViewCell.m
//  Prizm
//
//  Created by Jonathan Boone on 10/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInsightTitleCellTableViewCell.h"
#import "STKInsightTarget.h"
#import "STKinsight.h"

@interface STKInsightTitleCellTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;

@end

@implementation STKInsightTitleCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.titleLabel setTextColor:STKTextColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInsightTarget:(STKInsightTarget *)insightTarget
{
    _insightTarget = insightTarget;
    [self.titleLabel setText:insightTarget.insight.title];
}

- (IBAction)shareInsight:(id)sender
{
    if (self.delegate) {
        [self.delegate shareInsight:self.insightTarget.insight];
    }
}

- (IBAction)titleAreaTapped:(id)sender
{
    if (self.delegate) {
        [self.delegate titleControlTapped:self.insightTarget];
    }
}

- (void)setFullBleed:(BOOL)fullBleed
{
    _fullBleed = fullBleed;
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setFrame:(CGRect)frame
{
    if (! [self isFullBleed]){
        frame.origin.x += 5;
        frame.origin.y -= 2;
        frame.size.height -=2;
        frame.size.width -= 10;
    }
    [super setFrame:frame];
}

@end
