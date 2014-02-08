//
//  STKCaptureOverlayView.m
//  Prism
//
//  Created by Joe Conway on 1/23/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCaptureOverlayView.h"

@implementation STKCaptureOverlayView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setUserInteractionEnabled:NO];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setCutRect:(CGRect)cutRect
{
    _cutRect = cutRect;
    [self setNeedsDisplay];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGSize sz = [self bounds].size;
    float w = sz.width;
    float h = sz.height;
    
    if(!CGRectIsEmpty([self cutRect])) {
        CGRect cut = CGRectInset([self cutRect], 1, 1);
        
        UIBezierPath *bp = [UIBezierPath bezierPath];
        [bp moveToPoint:CGPointMake(0, 0)];
        [bp addLineToPoint:CGPointMake(w, 0)];
        [bp addLineToPoint:CGPointMake(w, h)];
        [bp addLineToPoint:CGPointMake(0, h)];
        [bp addLineToPoint:CGPointMake(0, cut.origin.y)];
        [bp addLineToPoint:CGPointMake(cut.origin.x, cut.origin.y)];
        [bp addLineToPoint:CGPointMake(cut.origin.x, cut.origin.y + cut.size.height)];
        [bp addLineToPoint:CGPointMake(cut.origin.x + cut.size.width, cut.origin.y + cut.size.height)];
        [bp addLineToPoint:CGPointMake(cut.origin.x + cut.size.width, cut.origin.y)];
        [bp addLineToPoint:CGPointMake(0, cut.origin.y)];
        [bp closePath];

        [bp addClip];
        [[self backgroundImage] drawInRect:[self bounds]];
    }
    
    
}


@end
