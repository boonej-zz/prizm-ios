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
@property (nonatomic, strong) NSMutableDictionary *nibMap;
@property (nonatomic, strong) NSMutableDictionary *reusePool;
@property (nonatomic, strong) NSMutableDictionary *bullshitRemap;
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
        _nibMap = [[NSMutableDictionary alloc] init];
        _reusePool = [[NSMutableDictionary alloc] init];
        _bullshitRemap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (UIImage *)blurredImageWithImage:(UIImage *)img
{
    float blurRadius = 5.0;
    CIImage *filterImage = [CIImage imageWithCGImage:[img CGImage]];
    
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    CGAffineTransform t = CGAffineTransformMakeScale(1, 1);
    [clampFilter setValue:[NSValue valueWithBytes:&t objCType:@encode(CGAffineTransform)]
                   forKey:@"inputTransform"];
    [clampFilter setValue:filterImage forKey:@"inputImage"];
    
    CIImage *clampedImage = [clampFilter outputImage];
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:clampedImage forKey:@"inputImage"];
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
    
    return [self blurredImageWithImage:img];
}


- (UIImage *)backgroundBlurredImageForView:(UIView *)view inSubrect:(CGRect)rect
{
    if(CGRectEqualToRect(rect, CGRectZero)) {
        rect = [view bounds];
    }
    
    float renderScale = 0.35;
    CGSize destinationSize = CGSizeMake((int)(rect.size.width * renderScale), (int)(rect.size.height * renderScale));
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(destinationSize.width, destinationSize.height), YES, 1.0);

    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, destinationSize.width, destinationSize.height));
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -rect.origin.x * renderScale, -rect.origin.y * renderScale);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), renderScale, renderScale);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [self blurredImageWithImage:img];
}

#pragma mark Table Views

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

        UIImage *img = [self backgroundBlurredImageForView:cell
                                                 inSubrect:CGRectZero];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reenqueueCell:cell];
            block(img);
        });
    });
}

@end
