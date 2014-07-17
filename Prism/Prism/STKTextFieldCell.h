//
//  STKTextFieldCell.h
//  Prism
//
//  Created by Joe Conway on 12/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@interface STKTextFieldCell : STKTableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) UIColor *backdropColor;
@property (nonatomic, strong) NSFormatter *textFormatter;

@end
