//
//  STKCommentTitleCell.m
//  Prizm
//
//  Created by Jonathan Boone on 11/4/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCommentTitleCell.h"

@implementation STKCommentTitleCell

- (void)awakeFromNib {
    // Initialization code
    [self.titleLabel setFont:STKFont(13)];
    [self.titleLabel setTextColor:STKTextColor];
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
    [[self layer] setShadowColor:[[UIColor whiteColor] CGColor]];
    [[self layer] setShadowOffset:CGSizeMake(0, -1)];
    [[self layer] setShadowOpacity:0.35];
    [[self layer] setShadowRadius:0];
    UIBezierPath *bp = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 320, 1)];
    [[self layer] setShadowPath:[bp CGPath]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
