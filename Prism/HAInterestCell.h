//
//  HAInterestCell.h
//  Prizm
//
//  Created by Jonathan Boone on 10/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKInterest;

@interface HAInterestCell : UICollectionViewCell

@property (nonatomic, strong) STKInterest *interest;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isStored) BOOL stored;

@end
