//
//  HAPostMessageView.m
//  Prizm
//
//  Created by Jonathan Boone on 4/29/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAPostMessageView.h"
@interface HAPostMessageView()<UITextFieldDelegate>
@property (nonatomic) BOOL constraintsAdded;
@end

@implementation HAPostMessageView

- (void)layoutSubviews
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self.iv setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.4f]];
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2f]];
    [self.textField setDelegate:self];
    [self.textField setTextColor:[UIColor HATextColor]];
    
    [self.iv setContentMode:UIViewContentModeCenter];
    [self.iv setImage:[UIImage imageNamed:@"icon_message_small"]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (self.delegate) {
        [self.delegate beganEditing:self];
    }

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard:textField];
    return YES;
}

- (void)dismissKeyboard:(id)sender
{
    [self.textField resignFirstResponder];
    if (self.delegate) {
        [self.delegate endEditing:self];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
