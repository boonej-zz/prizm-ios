//
//  HAAvatarImageCell.m
//  Prizm
//
//  Created by Jonathan Boone on 4/27/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAAvatarImageCell.h"


@implementation HAAvatarImageCell

- (void)awakeFromNib {
    // Initialization code
    [self.title setFont:STKFont(18.0f)];
    [self.title setTextColor:[UIColor HATextColor]];
    [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 48.0f)];
    [self setSelectedBackgroundView:bgView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
