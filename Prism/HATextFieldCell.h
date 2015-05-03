//
//  HATextFieldCell.h
//  Prizm
//
//  Created by Jonathan Boone on 5/2/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HACellProtocol.h"


@interface HATextFieldCell:UITableViewCell <HACellProtocol>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, weak) id<HACellDelegateProtocol> delegate;

@end
