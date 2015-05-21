//
//  HAPostMessageView.m
//  Prizm
//
//  Created by Jonathan Boone on 4/29/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAPostMessageView.h"

@interface HAPostMessageView()<UITextViewDelegate>
@property (nonatomic) BOOL constraintsAdded;

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *tintView;
@property (nonatomic) BOOL textViewHasText;

@end

@implementation HAPostMessageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [self.blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_blurView];
        self.tintView = [[UIView alloc] init];
        [self.tintView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.34f]];
        [[self.blurView contentView] addSubview:self.tintView];
        self.textView = [[UITextView alloc] init];
        [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.iv = [[UIImageView alloc] init];
        [self.iv setTranslatesAutoresizingMaskIntoConstraints:NO];
//        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.actionButton = [[UIButton alloc] init];
        [self.actionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.placeholder = [[UILabel alloc] init];
        [self.placeholder setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.textView addSubview:self.placeholder];
        [self.textView setClipsToBounds:NO];
        [self addSubview:self.textView];
        [self addSubview:self.iv];
        [self addSubview:self.actionButton];
        self.textViewHasText = NO;
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bv]-0-|" options:0 metrics:nil views:@{@"bv": _blurView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bv]-0-|" options:0 metrics:nil views:@{@"bv": _blurView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[ab]-0-|" options:0 metrics:nil views:@{@"ab": _actionButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[tv]-0-|" options:0 metrics:nil views:@{@"tv": _textView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[iv]-15-[tv]-8-[ab]-0-|" options:0 metrics:nil views:@{@"tv": _textView, @"iv": _iv, @"ab": _actionButton}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_iv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_iv attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_iv attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_iv attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[p]-8-|" options:0 metrics:nil views:@{@"p": _placeholder}]];
    [self.textView addConstraint:[NSLayoutConstraint constraintWithItem:_placeholder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_textView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.textView addConstraint:[NSLayoutConstraint constraintWithItem:_placeholder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_textView attribute:NSLayoutAttributeCenterY multiplier:1 constant:-4.f]];
    [self.actionButton addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:46.f]];
    [self.actionButton addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:46.f]];
}

- (void)sendTapped:(id)sender
{
    [self showActionButton:NO];
    if ([self.textView isFirstResponder]) {
        [self dismissKeyboard:self];
    }
    
}

- (void)addTapped:(id)sender
{
    [self showActionButton:NO];
    if (self.delegate) {
        [self.delegate addButtonTapped:self];
    }
    
}

- (void)layoutSubviews
{
    [self.tintView setFrame:self.bounds];
    [self.iv setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.4f]];
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2f]];
    [self.textView setDelegate:self];
    [self.textView setTextColor:[UIColor HATextColor]];
    [self.textView setFont:STKFont(15)];
    [self.iv setContentMode:UIViewContentModeCenter];
    [self.iv setImage:[UIImage imageNamed:@"icon_message_small"]];
    [self.placeholder setTextColor:[UIColor HATextColor]];
    [self.placeholder setFont:STKFont(15)];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    [self.textView setKeyboardType:UIKeyboardTypeTwitter];
    if (!self.textView.text.length > 0) {
        [self.actionButton removeTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton addTarget:self action:@selector(addTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton setImage:[UIImage imageNamed:@"message_plus"] forState:UIControlStateNormal];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.actionButton setImage:nil forState:UIControlStateNormal];
    [self.actionButton removeTarget:self action:@selector(addTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.placeholder setHidden:YES];
    if (self.delegate) {
        [self.delegate beganEditing:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.textView setTintColor:[UIColor HATextColor]];
    [self.textView setFont:STKFont(15)];
    if (textView.text.length > 0) {
        if (!self.textViewHasText) {
            self.textViewHasText = YES;
            [self showActionButton:YES];
        }
    } else {
        self.textViewHasText = NO;
        [self.actionButton setImage:nil forState:UIControlStateNormal];
        [self.actionButton removeTarget:self action:@selector(addTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.delegate postTextChanged:textView.text];
    
}

- (void)showActionButton:(BOOL)textEntry
{
    if (textEntry) {
        [self.actionButton removeTarget:self action:@selector(addTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *img = [UIImage imageNamed:@"btn_create_message"];
        [self.actionButton setImage:img forState:UIControlStateNormal];
        [self.actionButton setImage:nil forState:UIControlStateSelected];
    } else {
        [self.actionButton removeTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton addTarget:self action:@selector(addTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton setImage:[UIImage imageNamed:@"message_plus"] forState:UIControlStateNormal];
        self.textViewHasText = NO;
    }
}

- (void)dismissKeyboard:(id)sender
{
    [self showActionButton:NO];
    [self.textView resignFirstResponder];
    if (self.delegate) {
        [self.delegate endEditing:self];
    }
}

- (void)setPlaceHolder:(NSString *)placeholder
{
    [self.placeholder setText:placeholder];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
