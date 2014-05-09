//
//  STKNavigationButton.m
//  Prism
//
//  Created by Joe Conway on 2/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKNavigationButton.h"
#import "STKNotifiedBadgeView.h"

@interface STKNavigationButton ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) STKNotifiedBadgeView *badgeView;
@end

@implementation STKNavigationButton
@synthesize badgeView = _badgeView;
- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 38, 38)];
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

- (void)setBadgeable:(BOOL)badgeable
{
    _badgeable = badgeable;
    if(_badgeable) {
        
        float size = 8;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [[UIScreen mainScreen] scale]);
        
        UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size, size)];
        [[UIColor colorWithRed:0.3 green:0.4 blue:.7 alpha:1] set];
        [p fill];
        
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _badgeView = [[STKNotifiedBadgeView alloc] initWithImage:img];
        [self addSubview:_badgeView];
        [_badgeView setFrame:CGRectMake(13, 8, size, size)];
        [_badgeView setHidden:YES];
    } else {
        [_badgeView removeFromSuperview];
        _badgeView = nil;
    }
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

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if([self isSelected]) {
        if([self selectedImage])
            [[self imageView] setImage:[self selectedImage]];
        else
            [[self imageView] setImage:[self image]];
    } else {
        [[self imageView] setImage:[self image]];
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[self imageView] setImage:[self highlightedImage]];
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
