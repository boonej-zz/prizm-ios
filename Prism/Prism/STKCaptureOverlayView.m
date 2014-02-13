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

- (void)setCutPath:(UIBezierPath *)cutPath
{
    _cutPath = cutPath;
    [self setNeedsDisplay];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{    
    if([self cutPath]) {
        [[UIColor colorWithWhite:0 alpha:0.9] set];
        UIRectFill([self bounds]);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDestinationOut);
        [[self cutPath] fill];
        
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeZero, 6, [[UIColor whiteColor] CGColor]);
        [[UIColor colorWithWhite:1 alpha:0.5] set];
        [[self cutPath] setLineWidth:2];
        [[self cutPath] stroke];

        [[self cutPath] setLineWidth:1];
        [[self cutPath] stroke];
}
    
    
}


@end
