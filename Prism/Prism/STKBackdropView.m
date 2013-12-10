//
//  STKBackdropView.m
//  Prism
//
//  Created by Joe Conway on 12/3/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKBackdropView.h"
#import "STKRenderServer.h"

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

@property (nonatomic, strong) NSMutableDictionary *nibMap;
@property (nonatomic, strong) NSMutableDictionary *reusePool;
@property (nonatomic, strong) NSMutableDictionary *bullshitRemap;
@property (nonatomic, strong) NSMutableArray *cellContainers;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *overlayView;

- (void)blurCell:(UITableViewCell *)cell
      completion:(void (^)(UIImage *result))block;

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
        _nibMap = [[NSMutableDictionary alloc] init];
        _reusePool = [[NSMutableDictionary alloc] init];
        _bullshitRemap = [[NSMutableDictionary alloc] init];
        _cellContainers = [[NSMutableArray alloc] init];
        
        [self setClipsToBounds:YES];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_backgroundImageView setBackgroundColor:[UIColor clearColor]];
        [_backgroundImageView setContentMode:UIViewContentModeTop];
        [self addSubview:_backgroundImageView];
        
        _overlayView = [[UIView alloc] initWithFrame:[self bounds]];
        [_overlayView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
//        [_overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5]];
        [self addSubview:_overlayView];

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
    [self setBackgroundColor:blurBackgroundColor];
}

- (void)setBlurBackgroundImage:(UIImage *)blurBackgroundImage
{
    UIImage *img = [[STKRenderServer renderServer] blurredImageWithImage:blurBackgroundImage
                                                             affineClamp:YES];
    _blurBackgroundImage = img;
    [[self backgroundImageView] setImage:img];
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
                [self insertSubview:iv belowSubview:[self overlayView]];
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


#pragma mark UITableView Support

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    [[self nibMap] setObject:nib forKey:identifier];
}

- (id)dequeueCellForReuseIdentifier:(NSString *)identifier
{
    NSMutableArray *a = [[self reusePool] objectForKey:identifier];
    if(!a) {
        a = [[NSMutableArray alloc] init];
        [[self reusePool] setObject:a forKey:identifier];
    }
    
    UITableViewCell *c = [a lastObject];
    if(!c) {
        c = [(UINib *)[[self nibMap] objectForKey:identifier] instantiateWithOwner:nil
                                                                           options:0][0];
        [[self bullshitRemap] setObject:identifier forKey:[NSValue valueWithNonretainedObject:c]];
    } else {
        [a removeObjectIdenticalTo:c];
    }
    
    return c;
}

- (void)reenqueueCell:(UITableViewCell *)cell
{
    NSMutableArray *a = [[self reusePool] objectForKey:[[self bullshitRemap] objectForKey:[NSValue valueWithNonretainedObject:cell]]];
    [a addObject:cell];
}

- (void)blurCell:(UITableViewCell *)cell
      completion:(void (^)(UIImage *result))block
{
    if(!block) {
        @throw [NSException exceptionWithName:@"STKRenderServerException"
                                       reason:@"Cannot pass nil to blurCell:completion:"
                                     userInfo:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *img = [[STKRenderServer renderServer] backgroundBlurredImageForView:cell
                                                 inSubrect:CGRectZero];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reenqueueCell:cell];
            block(img);
        });
    });
}


- (void)addBlurredImageFromCell:(UITableViewCell *)cell
                        forRect:(CGRect)rect
                      indexPath:(NSIndexPath *)ip
{
    [self blurCell:cell
        completion:^(UIImage *result) {
            STKBackdropViewImage *i = [[STKBackdropViewImage alloc] init];
            [i setImage:result];
            [i setRect:rect];
            [i setIndexPath:ip];
            
            [[self images] addObject:i];
            [[self cacheMap] setObject:i
                                forKey:ip];
        }];
}

- (BOOL)shouldBlurImageForIndexPath:(NSIndexPath *)ip
{
    return ([[self cacheMap] objectForKey:ip] == nil);
}

@end
