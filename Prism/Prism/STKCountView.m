//
//  STKCountView.m
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKCountView.h"

@interface STKCountCircleView : UIControl

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation STKCountCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setTextColor:[UIColor HATextColor]];
        [_countLabel setTextColor:[UIColor HATextColor]];
        [_titleLabel setMinimumScaleFactor:0.5];
        [_countLabel setMinimumScaleFactor:0.5];
        [_titleLabel setFont:STKFont(16)];
        [_countLabel setFont:STKFont(16)];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [_countLabel setAdjustsFontSizeToFitWidth:YES];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_countLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_countLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:_titleLabel];
        [self addSubview:_countLabel];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[v]-8-|" options:0 metrics:nil views:@{@"v" : _titleLabel}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-1]];
        [_titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1 constant:20]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[v]-8-|" options:0 metrics:nil views:@{@"v" : _countLabel}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-1]];
        [_countLabel addConstraint:[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1 constant:20]];
        [self setBackgroundColor:[UIColor clearColor]];

        [self setContentMode:UIViewContentModeRedraw];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithWhite:1.0 alpha:0.2] setFill];
    [[UIColor colorWithWhite:1.0 alpha:0.5] setStroke];

    CGRect r = CGRectInset([self bounds], 1, 1);
    if(r.size.width < r.size.height)
        r.size.height = r.size.width;
    else if(r.size.height < r.size.width)
        r.size.width = r.size.height;
    
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:r];
    [bp setLineWidth:2];
    [bp fill];
    [bp stroke];
}

@end

@interface STKCountView ()
@property (nonatomic, strong) NSArray *circleViews;
@end

@implementation STKCountView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSMutableArray *a = [NSMutableArray array];
    for(int i = 0; i < 3; i++) {
        STKCountCircleView *c = [[STKCountCircleView alloc] init];
        [c addTarget:self action:@selector(circleTapped:) forControlEvents:UIControlEventTouchUpInside];
        [c setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:c];
        [a addObject:c];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v" : c}]];
    }
    _circleViews = [a copy];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[v0]-8-[v1(==v0)]-8-[v2(==v0)]-14-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"v0" : a[0], @"v1" : a[1], @"v2" : a[2]}]];
}

- (void)circleTapped:(id)sender
{
    int idx = (int)[[self circleViews] indexOfObject:sender];
    [[self delegate] countView:self didSelectCircleAtIndex:idx];
}

- (void)setCircleTitles:(NSArray *)circleTitles
{
    if([circleTitles count] != 3) {
        @throw [NSException exceptionWithName:@"STKCountViewException" reason:@"Therem ust be 3 circles" userInfo:nil];
    }
    _circleTitles = [circleTitles copy];
    
    for(int i = 0; i < 3; i++) {
        [[[[self circleViews] objectAtIndex:i] titleLabel] setText:[[self circleTitles] objectAtIndex:i]];
    }
}

- (void)setCircleValues:(NSArray *)circleValues
{
    if([circleValues count] != 3) {
        @throw [NSException exceptionWithName:@"STKCountViewException" reason:@"Therem ust be 3 circles" userInfo:nil];
    }

    _circleValues = [circleValues copy];
    
    for(int i = 0; i < 3; i++) {
        [[[[self circleViews] objectAtIndex:i] countLabel] setText:[[self circleValues] objectAtIndex:i]];
    }
}



@end
