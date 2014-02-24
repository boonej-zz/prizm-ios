//
//  STKNavigationButton.m
//  Prism
//
//  Created by Joe Conway on 2/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKNavigationButton.h"

@interface STKNavigationButton ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation STKNavigationButton

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 36, 36)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _imageView = [[UIImageView alloc] init];
        [_imageView setContentMode:UIViewContentModeCenter];
        [_imageView setFrame:[self bounds]];
        [_imageView setClipsToBounds:NO];
        [self setClipsToBounds:NO];
        [self addSubview:_imageView];
    }
    return self;

}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [[self imageView] setImage:image];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (void)setOffset:(float)offset
{
    _offset = offset;
    CGRect r = [self bounds];
    r.origin.x = offset;
    [[self imageView] setFrame:r];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[self imageView] setImage:[self selectedImage]];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[self imageView] setImage:[self image]];

}
/*
- (void)drawRect:(CGRect)rect
{
    UIImage *img = [self image];
    if([self state] != UIControlStateNormal) {
        img = [self selectedImage];
    }
    
    CGSize sz = [img size];
    NSLog(@"%@", NSStringFromCGRect([self frame]));
    float wDelta = ([self bounds].size.width - sz.width) / 2.0;
    float hDelta = ([self bounds].size.height - sz.height) / 2.0;
    NSLog(@"%f %f", wDelta, hDelta);
    [img drawInRect:CGRectMake(wDelta + [self offset], hDelta, sz.width, sz.height)];
}*/


@end
