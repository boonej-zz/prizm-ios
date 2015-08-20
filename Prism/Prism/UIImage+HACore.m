//
//  UIImage+HACore.m
//  Prizm
//
//  Created by Jonathan Boone on 11/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "UIImage+HACore.h"
#import "STKTheme.h"
#import "STKUser.h"
#import "STKUserStore.h"
#import "STKOrganization.h"

@implementation UIImage (HACore)

+ (UIImage *)HABackgroundImage
{
    NSString *imageName = @"img_background";
//    static NSString * HABackgroundThemeURL = nil;
    STKTheme *theme = nil;
    STKUser *user = [[STKUserStore store] currentUser];
    if ([user.type isEqualToString:STKUserTypeInstitution]) {
        theme = user.theme;
    } else {
        STKOrganization *org = [[STKUserStore store] activeOrgForUser];
        if (org) {
            theme = org.theme;
        }
    }
    if (theme) {
        if (theme.backgroundURL) {
            imageName = [imageName stringByAppendingString:[NSString stringWithFormat:@"_%@", theme.backgroundURL]];
        }
//        if (! HABackgroundThemeURL) {
//            HABackgroundThemeURL = imageName;
//        }
    }
    
    UIImage *img =  [UIImage imageNamed:imageName];
    return img;
}

+ (UIImage *)HAPatternImage:(UIImage *)image withHeight:(CGFloat)height andWidth:(CGFloat)width bgColor:(UIColor *)color
{
    CGSize backgroundSize = CGSizeMake(width * 2, height * 2);
    UIGraphicsBeginImageContext(backgroundSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect backgroundRect;
    backgroundRect.size.width = backgroundSize.width;
    backgroundRect.size.height = backgroundSize.height -2;
    backgroundRect.origin.x = 0;
    backgroundRect.origin.y = 2;
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBFillColor(ctx, r, g, b, a);
    CGContextFillRect(ctx, backgroundRect);
    
    CGRect imageRect;
    imageRect.size = image.size;
    imageRect.origin.x = (backgroundSize.width - image.size.width)/2;
    imageRect.origin.y = (backgroundSize.height - image.size.height)/2;
    
    // Unflip the image
    CGContextTranslateCTM(ctx, 0, backgroundSize.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextDrawImage(ctx, imageRect, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:newImage.CGImage scale:2.f orientation:UIImageOrientationUp];
}

@end
