//
//  STKRenderServer.m
//  Prism
//
//  Created by Joe Conway on 11/25/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKRenderServer.h"

@import QuartzCore;
@import CoreImage;

@interface STKRenderServer ()

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
        _context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
    }
    return self;
}

- (UIImage *)blurredImageWithImage:(UIImage *)img affineClamp:(BOOL)clamp
{
    float blurRadius = 2.0;
    CIImage *filterImage = [CIImage imageWithCGImage:[img CGImage]];
    CIImage *clampedImage = nil;
    
    if(clamp) {
        CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
        CGAffineTransform t = CGAffineTransformMakeScale(1, 1);
        [clampFilter setValue:[NSValue valueWithBytes:&t objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
        [clampFilter setValue:filterImage forKey:@"inputImage"];
        
        clampedImage = [clampFilter outputImage];
    } else {
        clampedImage = filterImage;
    }
    
    CIFilter *whitepoint = [CIFilter filterWithName:@"CIWhitePointAdjust"];
    [whitepoint setValue:clampedImage forKey:@"inputImage"];
    [whitepoint setValue:[CIColor colorWithRed:0.5 green:0.5 blue:0.6 alpha:1.0] forKey:@"inputColor"];
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:[whitepoint outputImage] forKey:@"inputImage"];
    [blurFilter setValue:@(blurRadius) forKey:@"inputRadius"];
    
    CGImageRef cgImg = [[self context] createCGImage:[blurFilter outputImage]
                                            fromRect:[filterImage extent]];
    
    UIImage *outImage = [UIImage imageWithCGImage:cgImg];
    
    CGImageRelease(cgImg);
    
    return outImage;
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
    //[[view layer] renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [self blurredImageWithImage:img affineClamp:YES];
}


- (UIImage *)backgroundBlurredImageForView:(UIView *)view
                                 inSubrect:(CGRect)rect
{
    if(CGRectEqualToRect(rect, CGRectZero)) {
        rect = [view bounds];
    }
    
    float renderScale = 0.35;
    CGSize destinationSize = CGSizeMake((int)(rect.size.width * renderScale),
                                        (int)(rect.size.height * renderScale) + 4);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(destinationSize.width, destinationSize.height), NO, 1.0);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -rect.origin.x * renderScale, -rect.origin.y * renderScale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, 2);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), renderScale, renderScale);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    /*
    [UIImagePNGRepresentation(img) writeToFile:@"/Users/joeconway/Desktop/image.png"
                                    atomically:YES];
    */
    return [self blurredImageWithImage:img affineClamp:YES];
}


@end
