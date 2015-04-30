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

@implementation UIImage (HACore)

+ (UIImage *)HABackgroundImage
{
    NSString *imageName = @"img_background";
    static NSString * HABackgroundThemeURL = nil;
    if (! HABackgroundThemeURL) {
    
        STKUser *user = [[STKUserStore store] currentUser];
        if ([user theme]) {
            if ([user theme].backgroundURL) {
               imageName = [imageName stringByAppendingString:[NSString stringWithFormat:@"_%@", [user theme].backgroundURL]];
            }
        }
        HABackgroundThemeURL = imageName;
    }
    UIImage *img =  [UIImage imageNamed:HABackgroundThemeURL];
    return img;
}

@end
