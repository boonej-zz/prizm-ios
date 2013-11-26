//
//  STKRenderServer.h
//  Prism
//
//  Created by Joe Conway on 11/25/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKRenderServer : NSObject

+ (STKRenderServer *)renderServer;

- (void)beginTrackingRenderingForScrollView:(UIScrollView *)view;
- (void)beginTrackingRenderingForScrollView:(UIScrollView *)view inSubrect:(CGRect)rect;
- (void)stopTrackingRenderingForScrollView:(UIScrollView *)view;

- (UIImage *)instantBlurredImageForView:(UIView *)view inSubrect:(CGRect)rect;

- (UIImage *)blurredImageForView:(UIView *)view;

@end
