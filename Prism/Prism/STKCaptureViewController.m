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

@interface STKCaptureViewController ()
@property (weak, nonatomic) IBOutlet STKCaptureView *captureView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageCaptureOutput;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, weak) IBOutlet STKCaptureOverlayView *overlayView;
@end

@implementation STKCaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)snapPhoto:(id)sender
{
    [[self imageCaptureOutput] captureStillImageAsynchronouslyFromConnection:[[self imageCaptureOutput] connectionWithMediaType:AVMediaTypeVideo]
                                                           completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                               if(!error) {
                                                                   NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                   UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                   CGSize sz = [image size];

                                                                   float destSize = 600.0;
                                                                   UIGraphicsBeginImageContextWithOptions(CGSizeMake(destSize, destSize), YES, 1.0);
                                                                   
                                                                   float s = destSize / sz.width;

                                                                   CGContextScaleCTM(UIGraphicsGetCurrentContext(), s, s);
                                                                   [image drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _session = [[AVCaptureSession alloc] init];
    [[self session] setSessionPreset:AVCaptureSessionPreset1280x720];
    [[self captureView] setSession:[self session]];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [devices firstObject];

    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [[self session] addInput:[self deviceInput]];
    
    _imageCaptureOutput = [[AVCaptureStillImageOutput alloc] init];
    [[self imageCaptureOutput] setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
    [[[self imageCaptureOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [[self session] addOutput:[self imageCaptureOutput]];
    
    [[self overlayView] setBackgroundImage:[UIImage imageNamed:@"img_background"]];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self session] startRunning];
    
    CGRect r = [[self captureView] frame];
    r.size.width = 300;
    r.size.height = 300;
    [[self overlayView] setCutRect:r];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self session] stopRunning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
