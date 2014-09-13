//
//  HAAccountSelectionCell.h
//  Prizm
//
//  Created by Jonathan Boone on 9/10/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKTableViewCell.h"

@class STKUser;

@interface HAAccountSelectionCell : STKTableViewCell

@property (nonatomic, strong) STKUser *account;

@end
