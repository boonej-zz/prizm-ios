//
//  STKBackdropView.m
//  Prism
//
//  Created by Joe Conway on 12/3/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKBackdropView.h"

static void * STKBackdropViewKVOContext = &STKBackdropViewKVOContext;

@interface STKBackdropViewImage : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGRect rect;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation STKBackdropViewImage
@end

@interface STKBackdropView ()

@property (nonatomic, strong) NSMutableDictionary *imageViews;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) CGRect relativeRect;
@property (nonatomic, getter = isRelativeRectSet) BOOL relativeRectSet;
@property (nonatomic, weak) UIView *blurView;
@property (nonatomic, strong) NSMutableDictionary *cacheMap;

@end

@implementation STKBackdropView

- (id)initWithFrame:(CGRect)frame relativeTo:(UIView *)blurView
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageViews = [[NSMutableDictionary alloc] init];
        _images = [[NSMutableArray alloc] init];
        _blurView = blurView;
        _cacheMap = [[NSMutableDictionary alloc] init];
        [self setClipsToBounds:YES];
        if([blurView isKindOfClass:[UIScrollView class]]) {
            [blurView addObserver:self
                       forKeyPath:@"contentOffset"
                          options:NSKeyValueObservingOptionNew
                          context:STKBackdropViewKVOContext];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    @throw [NSException exceptionWithName:@"STKBackdropViewException"
                                   reason:@"Use initWithFrame:relativeTo:"
                                 userInfo:nil];
}

- (void)setBlurBackgroundColor:(UIColor *)blurBackgroundColor
{
    _blurBackgroundColor = blurBackgroundColor;
    [self setBlurBackgroundImageFromColor:_blurBackgroundColor];
}

- (void)setBlurBackgroundImageFromColor:(UIColor *)color
{
    
}

- (void)addBlurredImage:(UIImage *)image forRect:(CGRect)rect indexPath:(NSIndexPath *)ip
{
    STKBackdropViewImage *i = [[STKBackdropViewImage alloc] init];
    [i setImage:image];
    [i setRect:rect];
    [i setIndexPath:ip];
    
    [[self images] addObject:i];
    [[self cacheMap] setObject:i
                        forKey:ip];
}

- (BOOL)shouldBlurImageForIndexPath:(NSIndexPath *)ip
{
    return ([[self cacheMap] objectForKey:ip] == nil);
}

- (void)invalidateCache
{
    [[self images] removeAllObjects];
    [[self cacheMap] removeAllObjects];
}

- (void)adjustImageViewsForScrollView:(UIScrollView *)sv
{
    if(![self isRelativeRectSet]) {
        [self setRelativeRectSet:YES];
        
        UIView *superview = [self superview];
        while(superview != nil) {
            if([sv isDescendantOfView:superview]) {
                break;
            }
            
            superview = [superview superview];
        }
        
        if(superview) {
            CGRect hostViewFrame = [[self superview] convertRect:[self frame]
                                                          toView:superview];
            CGRect blurViewFrame = [[sv superview] convertRect:[sv frame]
                                                        toView:superview];
            
            CGPoint offset = CGPointMake(hostViewFrame.origin.x - blurViewFrame.origin.x ,
                                         hostViewFrame.origin.y - blurViewFrame.origin.y);
            
            CGRect relativeRect = hostViewFrame;
            relativeRect.origin = offset;
            
            [self setRelativeRect:relativeRect];
        }
    }
    // Blurred rectangles are in 'native' coordinate system, that is, they don't
    // give a shit about insets.
    CGRect relative = [self relativeRect];
    CGPoint offset = [sv contentOffset];

    NSMutableArray *unusedKeys = [[[self imageViews] allKeys] mutableCopy];
    int counter = 0;
    for(STKBackdropViewImage *image in [self images]) {
        CGRect adjustedRect = [image rect];
        adjustedRect.origin.y -= offset.y;
        if(CGRectIntersectsRect(relative, adjustedRect)) {
            float internalOffset = adjustedRect.origin.y - relative.origin.y;
            
            UIImageView *iv = [[self imageViews] objectForKey:[image indexPath]];
            if(!iv) {
                iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [image rect].size.width, [image rect].size.height)];
                [iv setImage:[image image]];
                [self addSubview:iv];
                [[self imageViews] setObject:iv forKey:[image indexPath]];
            }
            
            CGRect r = [iv frame];
            r.origin.y = internalOffset;
            [iv setFrame:r];
            
            [unusedKeys removeObject:[image indexPath]];
        }
        counter++;
    }
    for(id key in unusedKeys) {
        UIImageView *iv = [[self imageViews] objectForKey:key];
        [iv removeFromSuperview];
    }
    [[self imageViews] removeObjectsForKeys:unusedKeys];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == STKBackdropViewKVOContext) {
        if([keyPath isEqualToString:@"contentOffset"]) {
            [self adjustImageViewsForScrollView:object];
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
@end
