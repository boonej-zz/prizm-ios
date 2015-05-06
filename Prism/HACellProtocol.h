//
//  HACellProtocol.h
//  Prizm
//
//  Created by Jonathan Boone on 5/2/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

@protocol HACellProtocol

@property (nonatomic, strong) UILabel *label;

@end

@protocol HACellDelegateProtocol<NSObject>

- (void)didEndEditingCell:(UITableViewCell<HACellProtocol> *)cell;

@optional
- (void)didUpdateCell:(UITableViewCell *)cell withText:(NSString *)text;

@end
