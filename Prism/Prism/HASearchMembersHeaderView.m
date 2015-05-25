//
//  HASeachMembersHeaderView.m
//  Prizm
//
//  Created by Jonathan Boone on 5/1/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASearchMembersHeaderView.h"

@interface HASearchMembersHeaderView()<UITextFieldDelegate>

@property (nonatomic, getter=didSetConstraints) BOOL setConstraints;
@property (nonatomic, strong) UIView *blurView;

@end

@implementation HASearchMembersHeaderView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self){
        [self setupView];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    _containerView = [[UIView alloc] init];
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _imageView = [[UIImageView alloc] init];
    [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _textField = [[UITextField alloc] init];
    [_textField setDelegate:self];
    [_textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_containerView addSubview:_imageView];
    [_containerView addSubview:_textField];
    [self addSubview:_containerView];
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints
{
    // Constraints for container
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:-1]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[v]-0-|" options:0 metrics:nil views:@{@"v": _containerView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v": _containerView}]];
    // Constraints for imageView and textField
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[iv(==22)]-12-[tf]-8-|" options:0 metrics:nil views:@{@"iv":_imageView, @"tf":_textField}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:22]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v":_textField}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

//    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v": _blurView}]];
//    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v": _blurView}]];

    self.setConstraints = YES;
}

- (void)updateConstraints
{
    if (![self didSetConstraints]) {
        [self setupConstraints];
    }
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setBackgroundColor:[UIColor clearColor]];
    [_containerView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
    [self.imageView setImage:[UIImage imageNamed:@"search_light"]];
    [self.textField setPlaceholder:@"Search by member"];
    [self setBackgroundColor:[UIColor clearColor]];
    [self.textField setTextColor:[UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:1.f]];
    [self.textField setFont:STKFont(15)];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    NSLog(@"%@", value);
    if ([self delegate]) {
        [[self delegate] searchTextChanged:value];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



@end
