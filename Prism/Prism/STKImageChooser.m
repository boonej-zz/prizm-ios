//
//  STKImageChooser.m
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKImageChooser.h"

@interface STKImageChooser () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
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
                                   completion:(void (^)(UIImage *))block
{
    [self setImageBlock:block];
    [self setSourceViewController:vc];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if(![self actionSheet]) {
            _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Image Source"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Camera", @"Photo Library", nil];
        }
        [[self actionSheet] showInView:[vc view]];
    } else {
        _imagePickerController = [[UIImagePickerController alloc] init];
        [_imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [_imagePickerController setDelegate:self];
        [[self sourceViewController] presentViewController:_imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];

    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [self imageBlock](img);
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [self imageBlock](nil);
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        [_imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        [_imagePickerController setDelegate:self];
        [[self sourceViewController] presentViewController:_imagePickerController
                                                  animated:YES
                                                completion:nil];
    } else if(buttonIndex == 1) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        [_imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [_imagePickerController setDelegate:self];
        [[self sourceViewController] presentViewController:_imagePickerController
                                                  animated:YES
                                                completion:nil];
    }
}

@end
