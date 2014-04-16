//
//  STKActivityIndicatorView.m
//  Activity
//
//  Created by Joe Conway on 4/15/14.
//  Copyright (c) 2014 Stable Kernel. All rights reserved.
//

#import "STKActivityIndicatorView.h"

@interface STKActivityIndicatorView ()
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation STKActivityIndicatorView

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

- (void)setTickColor:(UIColor *)tickColor
{
    _tickColor = tickColor;
    [self setNeedsDisplay];
    [[self activityView] setColor:_tickColor];
}

- (void)commonInit
{
    [self setHidden:YES];
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityView setHidesWhenStopped:YES];
    [self addSubview:_activityView];
    [_activityView setFrame:[self bounds]];
    [self setTickColor:[UIColor whiteColor]];

    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setRefreshing:(BOOL)refreshing
{
    _refreshing = refreshing;
    if(_progress == 0.0 && ![self refreshing]) {
        [self setHidden:YES];
    } else {
        [self setHidden:NO];
    }

    [self setNeedsDisplay];
    
    if(refreshing)
        [[self activityView] startAnimating];
    else {
        [[self activityView] stopAnimating];
    }
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if(_progress == 0.0 && ![self refreshing]) {
        [self setHidden:YES];
    } else {
        [self setHidden:NO];

    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if(![self refreshing]) {
        int ticks = 12 * [self progress];
        
        float cx = [self bounds].size.width / 2.0;
        float cy = [self bounds].size.height / 2.0;
        float radius = ([self bounds].size.width / 2.0) * 0.85;
        float radiusInterior = ([self bounds].size.width / 2.0) * 0.525;
        
        UIBezierPath *bp = [UIBezierPath bezierPath];
        for(int i = 0; i < ticks; i++) {
            float xAngle = cos(-M_PI / 2.0 + ((float)(i) / 12.0) * 2.0 * M_PI);
            float yAngle = sin(-M_PI / 2.0 + ((float)(i) / 12.0) * 2.0 * M_PI);
            [bp moveToPoint:CGPointMake(cx + radiusInterior * xAngle, cy + radiusInterior * yAngle)];
            [bp addLineToPoint:CGPointMake(cx + radius * xAngle, cy + radius * yAngle)];
        }
        [[self tickColor] set];
        [bp setLineWidth:1.75];
        [bp setLineCapStyle:kCGLineCapRound];
        [bp stroke];
    } else {

        /*int ticks = 12;
        
        float cx = [self bounds].size.width / 2.0;
        float cy = [self bounds].size.height / 2.0;
        float radius = ([self bounds].size.width / 2.0) * 0.85;
        float radiusInterior = ([self bounds].size.width / 2.0) * 0.525;
        
        
        for(int i = 0; i < ticks; i++) {
        UIBezierPath *bp = [UIBezierPath bezierPath];
            float xAngle = cos(-M_PI / 2.0 + ((float)(i) / 12.0) * 2.0 * M_PI);
            float yAngle = sin(-M_PI / 2.0 + ((float)(i) / 12.0) * 2.0 * M_PI);
            [bp moveToPoint:CGPointMake(cx + radiusInterior * xAngle, cy + radiusInterior * yAngle)];
            [bp addLineToPoint:CGPointMake(cx + radius * xAngle, cy + radius * yAngle)];
            
            float t = i / 11.0;
                float adjustedT = (t) * 0.7 + 0.3;
                
                [[[self tickColor] colorWithAlphaComponent:adjustedT] set];

            [bp setLineWidth:3];
            [bp setLineCapStyle:kCGLineCapRound];
            [bp stroke];
        }*/

    }
}

@end
