//
//  STKCaptureViewController.m
//  Prism
//
//  Created by Joe Conway on 1/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCaptureViewController.h"
#import "STKCaptureView.h"
#import "STKCaptureOverlayView.h"

@import AVFoundation;

@interface STKCaptureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UILabel *flashLabel;
@property (weak, nonatomic) IBOutlet UIButton *flipCameraButton;
@property (weak, nonatomic) IBOutlet STKCaptureView *captureView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageCaptureOutput;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, weak) IBOutlet STKCaptureOverlayView *overlayView;

@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation STKCaptureViewController
@synthesize imagePickerController = _imagePickerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIImagePickerController *)imagePickerController
{
    
    if(!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        [_imagePickerController setDelegate:self];
        [_imagePickerController setAllowsEditing:YES];
        [_imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    return _imagePickerController;
}

- (IBAction)dismiss:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleFlashMode:(id)sender
{
    AVCaptureFlashMode mode = [[[self deviceInput] device] flashMode];

    if([[[self deviceInput] device] lockForConfiguration:nil]) {
        if(mode == AVCaptureFlashModeAuto) {
            [[[self deviceInput] device] setFlashMode:AVCaptureFlashModeOn];
        } else if(mode == AVCaptureFlashModeOn) {
            [[[self deviceInput] device] setFlashMode:AVCaptureFlashModeOff];
        } else if (mode == AVCaptureFlashModeOff) {
            [[[self deviceInput] device] setFlashMode:AVCaptureFlashModeAuto];
        }
        [[[self deviceInput] device] unlockForConfiguration];
    }
    [self configureInterface];
}
- (void)configureInterface
{
    [[self flipCameraButton] setHidden:([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] <= 1)];
    
    if([[[self deviceInput] device] isFlashAvailable]) {
        [[self flashLabel] setHidden:NO];
        [[self flashButton] setHidden:NO];

        AVCaptureFlashMode mode = [[[self deviceInput] device] flashMode];
        if(mode == AVCaptureFlashModeAuto) {
            [[self flashLabel] setText:@"Auto"];
        } else if(mode == AVCaptureFlashModeOn) {
            [[self flashLabel] setText:@"On"];
        } else if (mode == AVCaptureFlashModeOff) {
            [[self flashLabel] setText:@"Off"];
        }
    } else {
        [[self flashLabel] setHidden:YES];
        [[self flashButton] setHidden:YES];
    }
}
- (IBAction)showLibrary:(id)sender
{
    [self presentViewController:[self imagePickerController]
                       animated:YES
                     completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)snapPhoto:(id)sender
{
    CGRect cropRect = [self rectForCameraArea];
    [[self imageCaptureOutput] captureStillImageAsynchronouslyFromConnection:[[self imageCaptureOutput] connectionWithMediaType:AVMediaTypeVideo]
                                                           completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                               if(!error) {
                                                                   NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                   UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                   CGSize sz = [image size];

                                                                   float destSize = 640.0;
                                                                   UIGraphicsBeginImageContextWithOptions(CGSizeMake(destSize, destSize), YES, 1.0);
                                                                   
                                                                   float s = destSize / sz.width;
                                                                   NSLog(@"%f", s);
                                                                   CGContextScaleCTM(UIGraphicsGetCurrentContext(), s, s);
                                                                   [image drawInRect:CGRectMake(0, -cropRect.origin.y * 2.0 / s, sz.width, sz.height)];
                                                                   UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
                                                                   UIGraphicsEndImageContext();
                                                                   
                                                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                       _capturedImage = croppedImage;
                                                                       [[self capturedImageView] setImage:croppedImage];
                                                                       [[self delegate] captureViewController:self didPickImage:croppedImage];
                                                                   }];
                                                               } else {
                                                                   
                                                               }
                                                           }];
}

- (IBAction)flipCamera:(id)sender
{
    AVCaptureDeviceInput *i = [self deviceInput];
    AVCaptureDevice *device = [i device];
    
    AVCaptureDevicePosition soughtPosition = AVCaptureDevicePositionBack;
    if([device position] == AVCaptureDevicePositionBack) {
        soughtPosition = AVCaptureDevicePositionFront;
    } else if([device position] == AVCaptureDevicePositionFront) {
        soughtPosition = AVCaptureDevicePositionBack;
    }
    

    AVCaptureDevice *newDevice = [self deviceForPosition:soughtPosition];
    if(newDevice) {
        [[self session] removeInput:[self deviceInput]];
        
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
        
        [[self session] addInput:[self deviceInput]];
    }
    [self configureInterface];
}

- (AVCaptureDevice *)deviceForPosition:(AVCaptureDevicePosition)pos
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *dev in devices) {
        if([dev position] == pos) {
            return dev;
        }
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _session = [[AVCaptureSession alloc] init];
    [[self session] setSessionPreset:AVCaptureSessionPreset1280x720];
    [[self captureView] setSession:[self session]];
    

    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [self deviceForPosition:AVCaptureDevicePositionBack];
    
    // We looked for a back camera, couldn't find it, defualt to whatever is in there.
    if(!device)
        device = [devices lastObject];
    
    if(!device) {
        // We have no devices!
        return;
    }
    
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [[self session] addInput:[self deviceInput]];
    
    _imageCaptureOutput = [[AVCaptureStillImageOutput alloc] init];
    [[self imageCaptureOutput] setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
    [[[self imageCaptureOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [[self session] addOutput:[self imageCaptureOutput]];
}

- (CGRect)rectForCameraArea
{
    CGRect top = [[self topBar] frame];
    CGRect bottom = [[self bottomBar] frame];
    
    top = [[self view] convertRect:top fromView:[[self topBar] superview]];
    bottom = [[self view] convertRect:bottom fromView:[[self bottomBar] superview]];
    
    CGRect r = CGRectMake(0, top.origin.y + top.size.height, 320, bottom.origin.y);
    r = [[self view] convertRect:r toView:[self captureView]];
    NSLog(@"%@", NSStringFromCGRect(r));
    return r;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[[self session] inputs] count] > 0)
        [[self session] startRunning];

    [self configureInterface];

//    [[self overlayView] setCutRect:[self rectForCameraArea]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self session] stopRunning];
}


@end
