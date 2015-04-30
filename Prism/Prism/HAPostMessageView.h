//
//  HAPostMessageView.h
//  Prizm
//
//  Created by Jonathan Boone on 4/29/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HAPostMessageView;

@protocol HAPostMessageViewDelegate

- (void)beganEditing:(HAPostMessageView *)sender;
- (void)endEditing:(HAPostMessageView *)sender;

@end

@interface HAPostMessageView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *iv;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, weak) id<HAPostMessageViewDelegate> delegate;

@end
