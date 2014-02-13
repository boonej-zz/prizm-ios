//
//  STKImageChooser.m
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKImageChooser.h"
#import "STKCaptureViewController.h"

@interface STKImageChooser () <STKCaptureViewControllerDelegate>
@property (nonatomic, strong) STKCaptureViewController *captureViewController;
@property (nonatomic, strong) void (^imageBlock)(UIImage *);
@property (nonatomic, weak) UIViewController *sourceViewController;
@end

@implementation STKImageChooser

+ (STKImageChooser *)sharedImageChooser
{
    static STKImageChooser *chooser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chooser = [[STKImageChooser alloc] init];
    });
    return chooser;
}

- (void)initiateImageChooserForViewController:(UIViewController *)vc
                                      forType:(STKImageChooserType)type
                                   completion:(void (^)(UIImage *))block
{
    [self setImageBlock:block];
    [self setSourceViewController:vc];
    

    _captureViewController = [[STKCaptureViewController alloc] init];
    [_captureViewController setDelegate:self];
    [_captureViewController setType:type];
    [[self sourceViewController] presentViewController:_captureViewController animated:YES completion:^{
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [[self captureViewController] showLibrary:nil];
        }
    }];
}

- (void)captureViewController:(STKCaptureViewController *)captureViewController didPickImage:(UIImage *)image
{
    [[captureViewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [self imageBlock](image);
    }];
}
@end
