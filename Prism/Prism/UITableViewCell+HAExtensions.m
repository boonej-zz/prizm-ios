//
//  UITableViewCell+HAExtensions.m
//  Prizm
//
//  Created by Jonathan Boone on 10/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "UITableViewCell+HAExtensions.h"

@implementation UITableViewCell (HAExtensions)

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
