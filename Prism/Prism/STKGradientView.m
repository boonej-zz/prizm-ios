//
//  STKGradientView.m
//  Prism
//
//  Created by Joe Conway on 4/17/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKGradientView.h"

@implementation STKGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

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
    CAGradientLayer *l = (CAGradientLayer *)[self layer];
    [l setStartPoint:CGPointMake(0.5, 1)];
    [l setEndPoint:CGPointMake(0.5, 0)];
    NSArray *colors = @[(__bridge id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (__bridge id)[[UIColor colorWithWhite:0 alpha:0.1] CGColor]];
    [l setColors:colors];

}


@end
