//
//  STKCircleView.m
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKCircleView.h"

@implementation STKCircleView

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
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect r = CGRectInset([self bounds], 2, 2);
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:r];
    [[UIColor lightGrayColor] set];
    [bp stroke];
    [bp addClip];
    [[self image] drawInRect:r];
}


@end
