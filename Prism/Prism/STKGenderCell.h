//
//  STKGenderCell.h
//  Prism
//
//  Created by Joe Conway on 12/10/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@interface STKGenderCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UIButton *notSetButton;
@property (nonatomic, strong) UIColor *backdropColor;

@end
