//
//  STKTrustView.m
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTrustView.h"
#import "STKCircleView.h"

@interface STKTrustView ()
@property (nonatomic, strong) NSArray *circleViews;
@end

@implementation STKTrustView

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
    for(int i = 0; i < 6; i++) {
        STKCircleView *sv = [[STKCircleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        [a addObject:sv];
        [self addSubview:sv];
    }
    [self setCircleViews:[a copy]];
    [[[self circleViews] objectAtIndex:0] setFrame:CGRectMake(0, 0, 82, 82)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect b = [self bounds];

    [[[self circleViews] objectAtIndex:0] setCenter:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [[[self circleViews] objectAtIndex:1] setCenter:CGPointMake(b.size.width / 4.0, b.size.height / 4.0)];
    [[[self circleViews] objectAtIndex:2] setCenter:CGPointMake(b.size.width / 2.0 + b.size.width / 6.0, b.size.height / 5.0)];
    [[[self circleViews] objectAtIndex:3] setCenter:CGPointMake(b.size.width / 2.0 + b.size.width / 3.0, b.size.height / 2.0 + b.size.height / 16.0)];
    [[[self circleViews] objectAtIndex:4] setCenter:CGPointMake(b.size.width / 2.0 + b.size.width / 6.0, b.size.height - b.size.height / 5.0)];
    [[[self circleViews] objectAtIndex:5] setCenter:CGPointMake(b.size.width / 3.5, b.size.height / 2.0 + b.size.height / 4.0)];
}


- (void)drawRect:(CGRect)rect
{
    CGRect b = [self bounds];
    [[UIColor colorWithWhite:1 alpha:0.4] set];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:CGPointMake(b.size.width / 4.0, b.size.height / 4.0)];

    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:CGPointMake(b.size.width / 2.0 + b.size.width / 6.0, b.size.height / 5.0)];

    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:CGPointMake(b.size.width / 2.0 + b.size.width / 3.0, b.size.height / 2.0 + b.size.height / 16.0)];
    
    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:CGPointMake(b.size.width / 2.0 + b.size.width / 6.0, b.size.height - b.size.height / 5.0)];

    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:CGPointMake(b.size.width / 3.5, b.size.height / 2.0 + b.size.height / 4.0)];
    
    [bp setLineWidth:2];
    [bp stroke];


}

@end
