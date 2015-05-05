//
//  HASearchMembersHeaderCellTableViewCell.m
//  Prizm
//
//  Created by Jonathan Boone on 5/1/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASearchMembersHeaderCellTableViewCell.h"

@interface HASearchMembersHeaderCellTableViewCell()

@property (nonatomic, weak) IBOutlet UITextField *textField;


@end

@implementation HASearchMembersHeaderCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.textField setBackgroundColor:[UIColor clearColor]];
    [self.textField setFont:STKFont(15)];
    [self.textField setTextColor:[UIColor HATextColor]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
