//
//  STKRenderServer.m
//  Prism
//
//  Created by Joe Conway on 11/25/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKRenderServer.h"
#import "STKRenderObject.h"

@import QuartzCore;
@import CoreImage;

@interface STKRenderServer ()

@property (nonatomic, strong) NSMutableDictionary *renderings;
@property (nonatomic, strong) CIContext *context;

@end

@implementation STKRenderServer

+ (STKRenderServer *)renderServer
{
    static STKRenderServer *server = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[STKRenderServer alloc] init];
    });
    
    return server;
}

- (id)init
{
    self = [super init];
    if(self) {
        _renderings = [[NSMutableDictionary alloc] init];
        _context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
    }
    return self;
}

- (UIImage *)instantBlurredImageForView:(UIView *)view inSubrect:(CGRect)rect
{
    if(CGRectEqualToRect(rect, CGRectZero)) {
        rect = [view bounds];
    }
    
    float renderScale = 0.35;
    CGSize destinationSize = CGSizeMake((int)(rect.size.width * renderScale), (int)(rect.size.height * renderScale));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(destinationSize.width, destinationSize.height), YES, 1.0);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -rect.origin.x * renderScale, -rect.origin.y * renderScale);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), renderScale, renderScale);

    [view drawViewHierarchyInRect:[view bounds]
               afterScreenUpdates:NO];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    float blurRadius = 5.0;
    CIImage *filterImage = [CIImage imageWithCGImage:[img CGImage]];
    
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    CGAffineTransform t = CGAffineTransformMakeScale(1, 1);
    [clampFilter setValue:[NSValue valueWithBytes:&t objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    [clampFilter setValue:filterImage forKey:@"inputImage"];

    CIImage *clampedImage = [clampFilter outputImage];
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:clampedImage forKey:@"inputImage"];
    [blurFilter setValue:@(blurRadius) forKey:@"inputRadius"];

    CGImageRef cgImg = [[self context] createCGImage:[blurFilter outputImage]
                                            fromRect:[filterImage extent]];
    
    UIImage *outImage = [UIImage imageWithCGImage:cgImg];
    
    return outImage;
}

- (void)beginTrackingRenderingForScrollView:(UIScrollView *)view inSubrect:(CGRect)rect
{
    NSLog(@"Size: %@", NSStringFromCGSize([view contentSize]));
    [view addObserver:self
           forKeyPath:@"contentOffset"
              options:NSKeyValueObservingOptionNew
              context:nil];
    /*
//    CGSize sourceSize = [view bounds].size;
    CGSize destinationSize = rect.size;
    float renderScale = 0.1;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(destinationSize.width *renderScale, destinationSize.height * renderScale), YES, 1.0);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -rect.origin.x * renderScale, -rect.origin.y * renderScale);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), renderScale, renderScale);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    STKRenderObject *obj = [[STKRenderObject alloc] init];
    [obj setImage:img];
    
    // Change to weak map???
    [[self renderings] setObject:obj forKey:[NSValue valueWithNonretainedObject:view]];*/
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UIScrollView *sv = (UIScrollView *)object;
    NSLog(@"%@", NSStringFromCGPoint([sv contentOffset]));
}

- (void)beginTrackingRenderingForScrollView:(UIScrollView *)view
{
    [self beginTrackingRenderingForScrollView:view inSubrect:[view bounds]];
}

- (void)stopTrackingRenderingForScrollView:(UIScrollView *)view
{
    
}

- (UIImage *)blurredImageForView:(UIView *)view
{
    return [[[self renderings] objectForKey:[NSValue valueWithNonretainedObject:view]] image];
}

@end
