//
//  STKAvatarView.m
//  Prism
//
//  Created by Joe Conway on 3/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKAvatarView.h"
#import "STKImageStore.h"


@implementation STKAvatarView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setUserInteractionEnabled:NO];
    [self setOutlineWidth:2];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOutlineColor:[UIColor colorWithRed:135 / 255.0 green:135 / 255.0 blue:162 / 255.0 alpha:1]];
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    
    [self setImage:nil];
    
    if(_urlString) {
        __weak STKAvatarView *iv = self;
        [[STKImageStore store] fetchImageForURLString:_urlString
                                        preferredSize:STKImageStoreThumbnailSmall
                                           completion:^(UIImage *img) {
                                               if([urlString isEqualToString:[iv urlString]]) {
                                                   [iv setImage:img];
                                                   [iv setNeedsDisplay];
                                               }
                                           }];
    }
    
}

- (void)setOverlayColor:(UIColor *)overlayColor
{
    _overlayColor = overlayColor;
    [self setNeedsDisplay];
}

- (void)setOutlineColor:(UIColor *)outlineColor
{
    _outlineColor = outlineColor;
    [self setNeedsDisplay];
}

- (void)setOutlineWidth:(CGFloat)outlineWidth
{
    _outlineWidth = outlineWidth;
    [self setNeedsDisplay];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
//    UIBezierPath *bpOuter = [UIBezierPath bezierPathWithOvalInRect:CGRectInset([self bounds], 1, 1)];
    UIBezierPath *bpInner = [UIBezierPath bezierPathWithOvalInRect:[self bounds]];

    UIGraphicsPushContext(UIGraphicsGetCurrentContext());
    [bpInner addClip];
    if([self image]) {
        [[self image] drawInRect:[self bounds]];
    } else {
        [[UIImage imageNamed:@"trust_user_missing"] drawInRect:[self bounds]];
    }
    
    if([self overlayColor]) {
        [[self overlayColor] set];
        [bpInner fill];
    }
    UIGraphicsPopContext();
    
    [[self outlineColor] set];
    [bpInner setLineWidth:[self outlineWidth]];
    [bpInner stroke];
}

@end
