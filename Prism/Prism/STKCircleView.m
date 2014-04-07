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
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if([self image]) {
        CGRect r = CGRectInset([self bounds], 2, 2);
        UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:r];
        if([self borderColor])
            [[self borderColor] set];
        else
            [STKTextColor set];
        [bp setLineWidth:4];
        [bp stroke];
        [bp addClip];
        
        [[self image] drawInRect:r];
        
        
        if([self overlayText]) {
            UIFont *f = STKFont(32);
            CGSize textSize = [[self overlayText] sizeWithAttributes:@{NSFontAttributeName : f}];
            
            [[self overlayText] drawInRect:CGRectMake((r.size.width - textSize.width) / 2.0,
                                                      (r.size.height - textSize.height) / 2.0, textSize.width, textSize.height)
                            withAttributes:@{NSFontAttributeName : f, NSForegroundColorAttributeName : [STKTextColor colorWithAlphaComponent:0.8]}];
        }
        
    } else {
        CGRect r = [self bounds];
        UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:r];
        if([self borderColor])
            [[self borderColor] set];
        else
            [STKTextColor set];
        [bp setLineWidth:4];
        [bp addClip];
        
        [[UIImage imageNamed:@"trust_user_missing"] drawInRect:r];
    }
}


@end
