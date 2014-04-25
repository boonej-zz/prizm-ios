//
//  STKNotificationBadge.m
//  Prism
//
//  Created by Joe Conway on 4/25/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKNotificationBadge.h"

@implementation STKNotificationBadge

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)setCount:(int)count
{
    _count = count;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if([self count] == 0)
        return;
    
    NSString *countString = [NSString stringWithFormat:@"%d", [self count]];
    
    UIFont *f = STKFont(12);
    UIColor *backgroundColor = [UIColor colorWithRed:0.3 green:0.4 blue:.7 alpha:1];
    
    CGSize sz = [countString sizeWithAttributes:@{NSFontAttributeName : f}];
    
    CGRect b = [self bounds];
    
    CGRect textRect = CGRectMake(b.size.width / 2.0 - sz.width / 2.0, b.size.height / 2.0 - sz.height / 2.0, sz.width, sz.height);
    
    UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(textRect, -6, -2) cornerRadius:10];
    [backgroundColor set];
    [bp fill];
    
    [countString drawInRect:textRect
             withAttributes:@{NSFontAttributeName : f, NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

@end
