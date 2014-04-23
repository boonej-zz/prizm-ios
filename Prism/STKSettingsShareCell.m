//
//  STKSettingsShareCell.m
//  Prism
//
//  Created by Joe Conway on 4/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSettingsShareCell.h"

@implementation STKSettingsShareCell

- (void)cellDidLoad
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    
    [[UIColor blackColor] set];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    
    [[self toggleSwitch] setOnImage:UIGraphicsGetImageFromCurrentImageContext()];
    [[self toggleSwitch] setOffImage:UIGraphicsGetImageFromCurrentImageContext()];

    UIGraphicsEndImageContext();
}

- (void)layoutContent
{
    
}

- (IBAction)toggleNetwork:(id)sender
{
    ROUTE(sender);
}
@end
