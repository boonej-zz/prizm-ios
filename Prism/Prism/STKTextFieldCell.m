//
//  STKTextFieldCell.m
//  Prism
//
//  Created by Joe Conway on 12/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTextFieldCell.h"

@interface STKTextFieldCell ()
@property (weak, nonatomic) IBOutlet UIView *backdropView;

@end


@implementation STKTextFieldCell

- (void)setBackdropColor:(UIColor *)backdropColor
{
    _backdropColor = backdropColor;
    [[self backdropView] setBackgroundColor:_backdropColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ROUTE(textField);
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldDidChange:(id)sender
{
    ROUTE(sender);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    ROUTE(textField);
}


- (void)cellDidLoad
{
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [[self contentView] addGestureRecognizer:tap];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)tap:(id)sender
{
    [[self textField] becomeFirstResponder];
}

- (void)layoutContent
{
    
}

@end