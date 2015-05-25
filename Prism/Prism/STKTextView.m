//
//  STKTextView.m
//  Prism
//
//  Created by Joe Conway on 4/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTextView.h"

@implementation STKTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"TB %@", touches);
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"TM %@", touches);
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"TE %@", touches);
    [super touchesEnded:touches withEvent:event];
    
}



@end
