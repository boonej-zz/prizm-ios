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
    STKTheme *theme = [[STKUserStore store] currentUser].theme;
    if (theme) {
        if (theme.backgroundURL) {
            imageName = [imageName stringByAppendingString:[NSString stringWithFormat:@"_%@", theme.backgroundURL]];
        }
    }
    UIImage *img =  [UIImage imageNamed:imageName];
    return img;
}

@end
