//
//  STKImageChooser.m
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKImageChooser.h"
#import "STKCaptureViewController.h"

//lipo -create './build-arm/libStaticLibDemo.a' './build-arm64/libStaticLibDemo.a' './build-i386/libStaticLibDemo.a' './build-x86_64/libStaticLibDemo.a' -output 'libStaticLibDemo.a'

@interface STKImageChooser () <STKCaptureViewControllerDelegate>
@property (nonatomic, strong) STKCaptureViewController *captureViewController;
@property (nonatomic, strong) void (^imageBlock)(UIImage *, UIImage *);
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
                                   completion:(void (^)(UIImage *, UIImage *))block
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

- (void)initiateImageEditorForViewController:(UIViewController *)vc
                                     forType:(STKImageChooserType)type
                                       image:(UIImage *)image
                                  completion:(void (^)(UIImage *, UIImage *))block
{
    [self setImageBlock:block];
    [self setSourceViewController:vc];
    
    _captureViewController = [[STKCaptureViewController alloc] init];
    [_captureViewController setDelegate:self];
    [_captureViewController setType:type];
    [_captureViewController setEditingImage:image];
    [[self sourceViewController] presentViewController:_captureViewController animated:YES completion:^{
    }];

}

- (void)captureViewController:(STKCaptureViewController *)captureViewController
                 didPickImage:(UIImage *)image
                originalImage:(UIImage *)originalImage
{
    [[captureViewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [self imageBlock](image, originalImage);
    }];
}
@end
