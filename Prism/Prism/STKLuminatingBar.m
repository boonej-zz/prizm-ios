//
//  STKLuminatingBar.m
//  Prism
//
//  Created by Joe Conway on 5/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLuminatingBar.h"
@import QuartzCore;

@interface STKLuminatingBar ()
@property (nonatomic, strong) CAGradientLayer *luminatingLayer;
@end

@implementation STKLuminatingBar

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
    [self setLuminationOpacity:0.5];
    [self setClipsToBounds:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    UIProgressView *pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [pv setProgress:1];
    [pv setFrame:[self bounds]];
    [self addSubview:pv];
    [self setProgressView:pv];
}

- (void)setProgress:(float)progress
{
    if([self luminating]) {
        [[self progressView] setProgress:0];
    } else {
        [[self progressView] setProgress:progress];
    }
}

- (float)progress
{
    return [[self progressView] progress];
}

- (void)setLuminating:(BOOL)luminating
{
    if(luminating == [self luminating])
        return;
    
    [[self progressView] setProgress:0];
    if(luminating) {
        _luminating = luminating;
        
        _luminatingLayer = [CAGradientLayer layer];
        [_luminatingLayer setFrame:CGRectMake(0, 0, [self bounds].size.width, [self bounds].size.height)];
        [_luminatingLayer setStartPoint:CGPointMake(0, 0)];
        [_luminatingLayer setEndPoint:CGPointMake(0, 1)];
        [_luminatingLayer setLocations:@[@0, @(0.5), @1]];
        [_luminatingLayer setColors:@[(id)[[UIColor colorWithWhite:1 alpha:0.0] CGColor],
                                      (id)[[UIColor colorWithWhite:1 alpha:[self luminationOpacity]] CGColor],
                                      (id)[[UIColor colorWithWhite:1 alpha:0.0] CGColor]]];
        [[self layer] addSublayer:_luminatingLayer];
        
        CABasicAnimation *cAnim = [CABasicAnimation animationWithKeyPath:@"colors"];
        [cAnim setFromValue:@[(id)[[UIColor colorWithWhite:1 alpha:[self luminationOpacity] * 0.2] CGColor],
                              (id)[[UIColor colorWithWhite:1 alpha:[self luminationOpacity] * 0.5] CGColor],
                              (id)[[UIColor colorWithWhite:1 alpha:0.0] CGColor]]];
        [cAnim setToValue:@[(id)[[UIColor colorWithWhite:1 alpha:[self luminationOpacity] * 0.5] CGColor],
                            (id)[[UIColor colorWithWhite:1 alpha:[self luminationOpacity]] CGColor],
                            (id)[[UIColor colorWithWhite:1 alpha:0.0] CGColor]]];
        [cAnim setDuration:1];
        [cAnim setRepeatCount:10000];
        [cAnim setAutoreverses:YES];
        
        [_luminatingLayer addAnimation:cAnim forKey:@"pulse"];
        
    } else {
        _luminating = luminating;
        CAGradientLayer *present = [[self luminatingLayer] presentationLayer];
//        NSArray *colors = [present colors];
//        NSLog(@"%@", colors);
//        UIColor *currentTopColor =
        [_luminatingLayer removeFromSuperlayer];
    }
}


@end
