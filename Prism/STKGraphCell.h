//
//  STKGraphCell.h
//  Prism
//
//  Created by Joe Conway on 5/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@interface STKGraphCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorWell;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end
