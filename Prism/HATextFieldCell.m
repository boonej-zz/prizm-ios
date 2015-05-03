//
//  HATextFieldCell.m
//  Prizm
//
//  Created by Jonathan Boone on 5/2/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HATextFieldCell.h"

@interface HATextFieldCell()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *containerView;

@end

@implementation HATextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell
{
    _containerView = [[UIView alloc] init];
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _label = [[UILabel alloc] init];
    [_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_containerView];
    [_containerView addSubview:_label];
    _textField = [[UITextField alloc] init];
    [_textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_textField setDelegate:self];
    [_containerView addSubview:_textField];
    [self setupConstraints];
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-13-[tl(==120)]-4-[tf]-|" options:0 metrics:nil views:@{@"tl": self.label, @"tf": self.textField}]];
//    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tl][tf]-0-|" options:0 metrics:nil views:@{@"tl": self.label, @"tf": self.textField}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)layoutSubviews {
    [[self label] setFont:STKFont(15.f)];
    [[self containerView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    [[self label] setTextColor:[UIColor whiteColor]];
    [[self textField] setFont:STKFont(14.f)];
    [[self textField] setTextColor:[UIColor HATextColor]];
    [[self textField] setBorderStyle:UITextBorderStyleNone];
    [[self textField] setBackgroundColor:[UIColor clearColor]];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [super layoutSubviews];
}


#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    [[self delegate] didEndEditingCell:self];
}

@end
