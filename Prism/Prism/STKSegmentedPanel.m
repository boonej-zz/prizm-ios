//
//  STKSegmentedPanel.m
//  Prism
//
//  Created by Joe Conway on 5/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSegmentedPanel.h"
#import "STKRenderServer.h"
#import "STKSegmentedControl.h"

@interface STKSegmentedPanel ()

@property (nonatomic, copy) NSArray *buttons;
@property (nonatomic, strong) UIView *buttonContainer;

@end

@implementation STKSegmentedPanel

- (void)presentInView:(UIView *)view
{
    [self setBackgroundColor:[UIColor clearColor]];

    [self setFrame:[view bounds]];
    [view addSubview:self];

    for(int i = 0; i < [[self items] count] / 3; i++) {

        NSMutableArray *items = [[NSMutableArray alloc] init];
        for(int j = i * 3; j <= i * 3 + 3; j++) {
            if(j < [[self items] count]) {
                [items addObject:[[self items] objectAtIndex:j]];
            }
        }
        
        
        STKSegmentedControl *c = [[STKSegmentedControl alloc] initWithItems:items];
        [c setFrame:CGRectMake(0, [view bounds].size.height - 50 * (i + 1), 320, 50)];
        [self addSubview:c];
        
    }
    [self setNeedsDisplay];
}

- (void)dismiss:(id)sender
{
    [self removeFromSuperview];
}

- (void)buttonTapped:(id)sender
{
    
}

- (void)drawRect:(CGRect)rect
{
    float w = [self bounds].size.width;
    float hStart = [self bounds].size.height - [[self buttonContainer] bounds].size.height;
    float h = [[self buttonContainer] bounds].size.height;
    
    [[UIColor colorWithRed:74.0/255.0 green:114.0/255.0 blue:153.0/255.0 alpha:0.8] set];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    [bp moveToPoint:CGPointMake(w / 3 - 1, hStart)];
    [bp addLineToPoint:CGPointMake(w / 3 - 1, hStart + h)];
    [bp moveToPoint:CGPointMake(2.0 * w / 3 + 1, hStart)];
    [bp addLineToPoint:CGPointMake(2.0 * w / 3 + 1, hStart + h)];
    [bp stroke];

}

@end
