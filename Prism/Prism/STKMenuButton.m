//
//  STKMenuButton.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKMenuButton.h"

@implementation STKMenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    [self setNeedsDisplay];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setHighlighted:YES];
    [self setNeedsDisplay];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(CGRectContainsPoint([self bounds], [touch locationInView:self])) {
        [self setHighlighted:YES];
        [self setNeedsDisplay];
    } else {
        [self setHighlighted:NO];
        [self setNeedsDisplay];
    }

    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self setHighlighted:NO];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setHighlighted:NO];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *bp = [UIBezierPath bezierPathWithRect:[self bounds]];
    [[UIColor colorWithRed:0 green:0 blue:.2 alpha:0.5] set];
    [bp stroke];
    
    UIImage *img = nil;
    UIColor *clr = nil;
    switch ([self state]) {
        case UIControlStateHighlighted:
        case UIControlStateSelected:
            img = [[self item] selectedImage];
            clr = [UIColor colorWithWhite:0.0 alpha:0.5];
            break;
            
        case UIControlStateNormal:
        case UIControlStateApplication:
        case UIControlStateDisabled:
        case UIControlStateReserved:
            img = [[self item] image];
            clr = [UIColor colorWithWhite:0.0 alpha:0.2];
            break;
            
        default:
            break;
    }
   
    CGRect b = CGRectInset([self bounds], .5, .5);
    [clr set];
    UIRectFill(b);
    
    CGSize sz = [img size];
    [img drawInRect:CGRectMake(b.size.width / 2.0 - sz.width / 2.0,
                               b.size.height / 2.0 - sz.height / 2.0,
                               sz.width, sz.height)];
}

@end
