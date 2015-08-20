//
//  UIColor+HACore.m
//  Prizm
//
//  Created by Jonathan Boone on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "UIColor+HACore.h"
#import "STKUserStore.h"
#import "STKTheme.h"
#import "STKOrganization.h"
#import "STKUser.h"

@implementation UIColor (HACore)

+ (UIColor *)HATextColor
{
    UIColor *c = [UIColor colorWithRed:192.0/255.0 green:193.0/255.0 blue:213.0/255.0 alpha:1];
    STKTheme *theme = [[STKUserStore store] currentUser].theme;
//    NSLog(@"%@", theme);
    if (theme && theme.textColor) {
        NSArray *color = [theme.textColor componentsSeparatedByString:@","];
        if ([color count] == 4) {
            double r = [color[0] doubleValue]/255.f;
            double g = [color[1] doubleValue]/255.f;
            double b = [color[2] doubleValue]/255.f;
            double a = [color[3] doubleValue];
            c = [UIColor colorWithRed:r green:g blue:b alpha:a];
        } 
    }
    return c;
}

+ (UIColor *)HALightTextColor
{
    UIColor *c = [UIColor colorWithRed:199.f/255.f green:208.f/255.f blue:209.f/255.f alpha:1.f];
    return c;
}

+ (UIColor *)HADominantColor
{
    UIColor *c = [UIColor colorWithRed:11.0/255.0 green:53.0/255.0 blue:110.0/255.0 alpha:0.95];
    STKUser *user = [[STKUserStore store] currentUser];
    STKTheme *theme = nil;
    if ([user.type isEqualToString:@"institution_verified"]) {
        theme = user.theme;
    } else {
        STKOrganization *org = [[STKUserStore store] activeOrgForUser];
        
        if (org && org.theme) {
            theme = org.theme;
        }
    }
    
//    NSLog(@"%@", theme);
    if (theme && theme.dominantColor) {
        NSArray *color = [theme.dominantColor componentsSeparatedByString:@","];
        if ([color count] == 4) {
            double r = [color[0] doubleValue]/255.f;
            double g = [color[1] doubleValue]/255.f;
            double b = [color[2] doubleValue]/255.f;
            double a = [color[3] doubleValue];
            c = [UIColor colorWithRed:r green:g blue:b alpha:a];
        }
    }
    return c;
}


@end
