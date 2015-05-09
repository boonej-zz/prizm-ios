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
- (void)postTextChanged:(NSString *)text;

@end

@interface HAPostMessageView : UIView

@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, weak) id<HAPostMessageViewDelegate> delegate;

- (void)setPlaceHolder:(NSString *)placeholder;
- (void)showActionButton:(BOOL)textEntry;

@end
