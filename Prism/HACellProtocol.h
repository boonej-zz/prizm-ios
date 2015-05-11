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



@optional
- (void)didEndEditingCell:(UITableViewCell<HACellProtocol> *)cell;
- (void)didUpdateCell:(UITableViewCell *)cell withText:(NSString *)text;
- (BOOL)shouldUpdateCell:(UITableViewCell *)cell withText:(NSString *)text;

@end
