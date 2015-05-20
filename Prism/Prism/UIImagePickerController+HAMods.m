//
//  UIImagePickerController+HAMods.m
//  Prizm
//
//  Created by Jonathan Boone on 5/19/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "UIImagePickerController+HAMods.h"

@implementation UIImagePickerController (HAMods)


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
}


- (BOOL)shouldAutorotate
{
    return NO;
}


@end
