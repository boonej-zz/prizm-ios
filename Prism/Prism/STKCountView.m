//
//  STKCountView.m
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKCountView.h"

@interface STKCountCircleView : UIView

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
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_countLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setMinimumScaleFactor:0.5];
        [_countLabel setMinimumScaleFactor:0.5];
        [_titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_countLabel setFont:[UIFont systemFontOfSize:20]];
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
                                                               multiplier:1 constant:24]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[v]-8-|" options:0 metrics:nil views:@{@"v" : _countLabel}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:1]];
        [_countLabel addConstraint:[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1 constant:24]];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithWhite:1.0 alpha:0.1] setFill];
    [[UIColor colorWithWhite:1.0 alpha:0.5] setStroke];
    
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:CGRectInset([self bounds], 5, 5)];
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
        [c setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:c];
        [a addObject:c];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v" : c}]];
    }
    _circleViews = [a copy];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[v0]-8-[v1(==v0)]-8-[v2(==v0)]-4-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"v0" : a[0], @"v1" : a[1], @"v2" : a[2]}]];
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
    
    [self setNeedsDisplay];
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

    
    [self setNeedsDisplay];
}



@end
