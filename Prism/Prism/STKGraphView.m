//
//  STKGraphView.m
//  Prism
//
//  Created by Joe Conway on 5/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKGraphView.h"

@implementation STKGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setXLabels:(NSArray *)xLabels
{
    _xLabels = xLabels;
    [self setNeedsDisplay];
}

- (void)setYLabels:(NSArray *)yLabels
{
    _yLabels = yLabels;
    [self setNeedsDisplay];
}

- (void)setValues:(NSArray *)values
{
    _values = values;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    int xLines = [[self xLabels] count];
    int yLines = [[self yLabels] count];
    
    float xInset = 40;
    float xBegin = xInset + 20;
    float xEnd = [self bounds].size.width - xInset;
    float xPer = (xEnd - xBegin) / (xLines - 1);
    
    UIFont *f = STKFont(14);
    
    float x = xBegin;
    for(int i = 0; i < xLines; i++) {
        [STKTextTransparentColor set];

        UIBezierPath *bp = [UIBezierPath bezierPath];
        [bp moveToPoint:CGPointMake(x, 8)];
        [bp addLineToPoint:CGPointMake(x, [self bounds].size.height)];
        [bp stroke];
        
      /*  NSString *xLabel = [[self xLabels] objectAtIndex:i];
        CGSize sz = [xLabel sizeWithAttributes:@{NSFontAttributeName : f}];
        [xLabel drawInRect:CGRectMake(x - sz.width / 2.0, [self bounds].size.height - sz.height - 2,
                                      sz.width, sz.height)
            withAttributes:@{NSFontAttributeName : f, NSForegroundColorAttributeName : STKTextTransparentColor}];
        */
        x += xPer;
    }

    float yBegin = 40;
    float yEnd = [self bounds].size.height;
    float yPer = (yEnd - yBegin) / (yLines - 1);

    float y = yBegin;
    for(int i = 0; i < yLines; i++) {
        [STKTextTransparentColor set];

        UIBezierPath *bp = [UIBezierPath bezierPath];
        [bp moveToPoint:CGPointMake(0, y)];
        [bp addLineToPoint:CGPointMake([self bounds].size.width, y)];
        [bp stroke];
        
        NSString *yLabel = [[self yLabels] objectAtIndex:yLines - i - 1];
        CGSize sz = [yLabel sizeWithAttributes:@{NSFontAttributeName : f}];
        [yLabel drawInRect:CGRectMake(30 - sz.width / 2.0, y - sz.height,
                                      sz.width, sz.height)
            withAttributes:@{NSFontAttributeName : f, NSForegroundColorAttributeName : [UIColor whiteColor]}];

        
        y += yPer;
    }
    
    for(NSDictionary *d in [self values]) {
        UIColor *c = [d objectForKey:@"color"];
        [[c colorWithAlphaComponent:0.65] set];
        
        UIBezierPath *bp = [UIBezierPath bezierPath];
        NSArray *ys = [d objectForKey:@"y"];
        
        float x = xBegin;
        NSMutableArray *points = [NSMutableArray array];
        for(int i = 0; i < [ys count]; i++) {
            CGPoint newPoint = CGPointMake(x, yEnd + [[ys objectAtIndex:i] floatValue] * (yBegin - yEnd));
            [points addObject:[NSValue valueWithCGPoint:newPoint]];
            x += xPer;
        }
        
        UIBezierPath *clip = [UIBezierPath bezierPathWithRect:CGRectMake(xBegin, yEnd, xEnd - xBegin, yBegin - yEnd)];
        [clip addClip];
        
        if([points count] > 1) {
            CGPoint prevControlPoint = CGPointZero;
            float scale = 10;
            for(int i = 0; i < [points count]; i++) {
                if(i == 0) {
                    CGPoint thisPoint = [[points objectAtIndex:i] CGPointValue];
                    [bp moveToPoint:thisPoint];
                    
                    prevControlPoint = CGPointMake(thisPoint.x + scale, thisPoint.y + scale);
                    
                    
                } else if(i == [points count] - 1) {
                    CGPoint thisPoint = [[points objectAtIndex:i] CGPointValue];
                    CGPoint lastPoint = [[points objectAtIndex:i - 1] CGPointValue];
                    
                    float length = hypotf(thisPoint.x - lastPoint.x, thisPoint.y - lastPoint.y);
                    CGPoint normalized = CGPointMake((thisPoint.x - lastPoint.x) / length, (thisPoint.y - lastPoint.y) / length);
                    CGPoint scaled = CGPointMake(normalized.x * scale, normalized.y * scale);

                    [bp addCurveToPoint:thisPoint
                          controlPoint1:prevControlPoint
                          controlPoint2:CGPointMake(thisPoint.x - scaled.x, lastPoint.y - scaled.y)];
                } else {
                    CGPoint thisPoint = [[points objectAtIndex:i] CGPointValue];
                    CGPoint lastPoint = [[points objectAtIndex:i - 1] CGPointValue];
                    CGPoint nextPoint = [[points objectAtIndex:i + 1] CGPointValue];
                    
                    float length = hypotf(nextPoint.x - lastPoint.x, nextPoint.y - lastPoint.y);
                    CGPoint normalized = CGPointMake((nextPoint.x - lastPoint.x) / length, (nextPoint.y - lastPoint.y) / length);
                    CGPoint scaled = CGPointMake(normalized.x * scale, normalized.y * scale);
                    
                    [bp addCurveToPoint:thisPoint
                          controlPoint1:prevControlPoint
                          controlPoint2:CGPointMake(thisPoint.x - scaled.x, thisPoint.y - scaled.y)];
                    
                    prevControlPoint = CGPointMake(thisPoint.x + scaled.x, thisPoint.y + scaled.y);
                }
            }
        }
        
        [bp addLineToPoint:CGPointMake(xEnd, yEnd)];
        [bp addLineToPoint:CGPointMake(xBegin, yEnd)];
        
        [bp fill];
        
    }

}


@end
