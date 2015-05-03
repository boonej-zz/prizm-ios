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

- (void)HASetDisclosureIndicator:(CGFloat)opacity
{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    [self setAccessoryView:iv];
    [self.accessoryView setBackgroundColor:[UIColor colorWithWhite:1 alpha:opacity]];
}

- (void)HAAddCellBackground:(CGFloat)opacity
{
    [self setBackgroundColor:[UIColor clearColor]];
    UIView *v = [[UIView alloc] init];
    [v setTranslatesAutoresizingMaskIntoConstraints:NO];
    [v setBackgroundColor:[UIColor colorWithWhite:1 alpha:opacity]];
    [self insertSubview:v atIndex:0];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[v]-0-|" options:0 metrics:nil views:@{@"v": v}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:nil views:@{@"v": v}]];
}

@end
