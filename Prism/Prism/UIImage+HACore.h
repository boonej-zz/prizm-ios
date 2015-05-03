//
//  UIImage+HACore.h
//  Prizm
//
//  Created by Jonathan Boone on 11/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HACore)

+ (UIImage *)HABackgroundImage;
+ (UIImage *)HAPatternImage:(UIImage *)image withHeight:(CGFloat)height andWidth:(CGFloat)width bgColor:(UIColor *)color;

@end
