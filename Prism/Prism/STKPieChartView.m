//
//  STKPieChartView.m
//  Prism
//
//  Created by Joe Conway on 5/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPieChartView.h"

@implementation STKPieChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setColors:(NSArray *)colors
{
    _colors = colors;
    [self setNeedsDisplay];
}

- (void)setValues:(NSArray *)values
{
    _values = values;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    float w = [self bounds].size.width;
    float h = [self bounds].size.height;
    float diameter = w;
    CGPoint center = CGPointMake(w / 2.0, h / 2.0);
    float arcRadius = diameter / 2.0 - 8.0;
    float lineWidth = 16;
    
    float angle = -M_PI / 2.0;
    for(int i = 0; i < [[self colors] count]; i++) {
        if(i < [[self values] count]) {
            [(UIColor *)[[self colors] objectAtIndex:i] set];
            
            float nextAngle = angle + [[[self values] objectAtIndex:i] floatValue] * M_PI * 2.0;
            UIBezierPath *bp = [UIBezierPath bezierPathWithArcCenter:center radius:arcRadius startAngle:angle endAngle:nextAngle clockwise:YES];
            [bp setLineWidth:lineWidth];
            [bp stroke];
            
            angle = nextAngle;
        }
    }
    
}

@end
