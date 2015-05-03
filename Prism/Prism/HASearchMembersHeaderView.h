//
//  HASeachMembersHeaderView.h
//  Prizm
//
//  Created by Jonathan Boone on 5/1/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HASearchMembersHeaderCellTableViewCell;

@protocol HASearchMembersDelegate

- (void)searchTextChanged:(NSString *)text;

@end

@interface HASearchMembersHeaderView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) id<HASearchMembersDelegate> delegate;

@end
