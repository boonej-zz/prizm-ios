//
//  STKDateCell.h
//  Prism
//
//  Created by Joe Conway on 12/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@interface STKDateCell : STKTableViewCell

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *defaultDate;
 
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
