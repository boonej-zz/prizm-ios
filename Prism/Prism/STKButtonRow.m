//
//  STKButtonRow.m
//  Prism
//
//  Created by Joe Conway on 4/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKButtonRow.h"

@interface STKButtonRow ()
@property (nonatomic, strong) NSArray *buttons;
@end

@implementation STKButtonRow

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

- (void)setImages:(NSArray *)images
{
    [[self buttons] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    for(UIImage *img in images) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:img forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [[button imageView] setContentMode:UIViewContentModeCenter];
        [self addSubview:button];
        [buttons addObject:button];
    }
    [self setButtons:buttons];
    
    _images = images;
    if([self currentIndex] >= [[self buttons] count])
        [self setCurrentIndex:0];
    
    [self configureInterface];
}

- (void)buttonTapped:(UIButton *)sender
{
    [self setCurrentIndex:(int)[[self buttons] indexOfObject:sender]];
    [self configureInterface];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)configureInterface
{
    if([[self buttons] count] == 0)
        return;
    
    NSMutableArray *visible = [NSMutableArray array];
    [visible addObjectsFromArray:[self buttons]];
    if([self currentIndex] < [visible count]) {
        [[visible objectAtIndex:[self currentIndex]] setHidden:YES];
        [visible removeObjectAtIndex:[self currentIndex]];
    }
    float w = [self bounds].size.width;
    float wPer = 40;
    
    float x = w - wPer;
    for(UIButton *b in visible) {
        [b setHidden:NO];
        [b setFrame:CGRectMake(x, 0, wPer, [self bounds].size.height)];
        x -= wPer;
    }
    
}

@end
