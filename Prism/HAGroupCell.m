//
//  HAGroupCell.m
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAGroupCell.h"

@implementation HAGroupCell

- (void)awakeFromNib {
    // Initialization code
    [self.title setFont:STKFont(18.0f)];
    [self.title setTextColor:[UIColor HATextColor]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 48.0f)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
    [self setSelectedBackgroundView:bgView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
