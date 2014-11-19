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
    STKOrganization *org = [[STKUserStore store] getOrganizationByCode:[[STKUserStore store] currentUser].programCode];
    if (org && org.theme.textColor) {
        NSArray *color = [org.theme.textColor componentsSeparatedByString:@","];
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
