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
#import "STKUser.h"

@import AVFoundation;

@interface STKCaptureViewController () <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UILabel *flashLabel;
@property (weak, nonatomic) IBOutlet UIButton *flipCameraButton;
@property (weak, nonatomic) IBOutlet STKCaptureView *captureView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageCaptureOutput;
@property (nonatomic, weak) IBOutlet STKCaptureOverlayView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *okayButton;
@property (nonatomic, strong) UIImage *capturedImage;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;

@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIScrollView *editScrollView;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UILabel *dimensionLabel;

@property (nonatomic) UIDeviceOrientation deviceOrientation;
@property (nonatomic) BOOL croppingImage;

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
        [_imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [[_imagePickerController navigationBar] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [[_imagePickerController navigationBar] setTranslucent:YES];
        
    }
    return _imagePickerController;
}

- (IBAction)dismiss:(id)sender
{
    if ([self croppingImage] == NO) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self setCroppingImage:NO];
        [self showLibrary:nil];
    }
}

- (IBAction)okayEdit:(id)sender
{
    float zoom = [[self editScrollView] zoomScale];
    CGSize sz = [[self editScrollView] contentSize];
    CGPoint p = [[self editScrollView] contentOffset];
    CGSize imgSize = [[self capturedImage] size];
    sz.width /= zoom;
    sz.height /= zoom;
    
    float diffX = (imgSize.width - sz.width) * zoom;
    float diffY = (imgSize.height - sz.height) * zoom;
    
    
    
    CGSize destSize = CGSizeMake(640, 640);
    if([self type] == STKImageChooserTypeCover) {
        destSize.height = STKUserCoverPhotoSize.height * 2.0;
        diffY += (640.0 - STKUserCoverPhotoSize.height * 2.0) / 2.0;
    }
    
    UIGraphicsBeginImageContextWithOptions(destSize, YES, 1.0);
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -p.x * 2.0 - diffX, -p.y * 2.0 - diffY);

    CGContextScaleCTM(UIGraphicsGetCurrentContext(), zoom * 2.0, zoom * 2.0);
    [[self capturedImage] drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    //[UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 1) writeToFile:@"/Users/joeconway/Desktop/image.jpg" atomically:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [[self delegate] captureViewController:self didPickImage:img originalImage:[self capturedImage]];
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
    if([self capturedImage]) {
        [[self editScrollView] setBackgroundColor:[UIColor blackColor]];
        [[self flipCameraButton] setHidden:YES];
        [[self flashButton] setHidden:YES];
        [[self flashLabel] setHidden:YES];
        [[self captureButton] setHidden:YES];
        [[self okayButton] setHidden:NO];
        if([self editingImage]) {
            [[self libraryButton] setHidden:YES];
        }
    } else {
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
        [[self editScrollView] setBackgroundColor:[UIColor clearColor]];
        
        [[self captureButton] setTitle:nil forState:UIControlStateNormal];
        [[self captureButton] setImage:[UIImage imageNamed:@"btn_camera"] forState:UIControlStateNormal];
        [[self okayButton] setHidden:YES];
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

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
}

- (IBAction)snapPhoto:(id)sender
{
    [[self imageCaptureOutput] captureStillImageAsynchronouslyFromConnection:[[self imageCaptureOutput] connectionWithMediaType:AVMediaTypeVideo]
                                                           completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                               if(!error) {
                                                                   NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                   UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                   
                                                                   UIImage *croppedImage;
                                                                   if ([self type] == STKImageChooserTypeCover && UIDeviceOrientationIsLandscape([self deviceOrientation])) {
                                                                       croppedImage = [self landscapeCroppedCoverCameraImage:image];
                                                                   } else {
                                                                       croppedImage = [self croppedCameraImage:image];
                                                                   }
                                                                   croppedImage = [self updateImageToCurrentOrientation:croppedImage];
                                                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                       _capturedImage = croppedImage;
                                                                       [[self capturedImageView] setImage:croppedImage];
                                                                       [[self delegate] captureViewController:self
                                                                                                 didPickImage:croppedImage
                                                                                                originalImage:image];
                                                                   }];
                                                               } else {
                                                                   
                                                               }
                                                           }];
}

- (UIImage *)croppedCameraImage:(UIImage *)image
{
    CGRect cropRect = [self rectForCameraArea];
    
    CGSize sz = [image size];
    float diffY = 0;
    CGSize destSize = CGSizeMake(640, 640);
    if ([self type] == STKImageChooserTypeCover) {
        destSize.height = STKUserCoverPhotoSize.height * 2.0;
        diffY += (640.0 - STKUserCoverPhotoSize.height * 2.0) / 2.0;
    }
    
    UIGraphicsBeginImageContextWithOptions(destSize, YES, 1.0);
    
    float s = destSize.width / sz.width;
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -diffY);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), s, s);
    [image drawInRect:CGRectMake(0, -cropRect.origin.y * 2.0 / s, sz.width, sz.height)];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

- (UIImage *)landscapeCroppedCoverCameraImage:(UIImage *)image
{
    CGRect cropRect = [self rectForCameraArea];

    CGSize sz = [image size];
    float diffX = 0;
    CGSize destSize = CGSizeMake(640, 640);
    if ([self type] == STKImageChooserTypeCover) {
        destSize.width = STKUserCoverPhotoSize.height * 2.0;
        diffX += (640.0 - STKUserCoverPhotoSize.height * 2.0) / 2.0;
    }
    
    UIGraphicsBeginImageContextWithOptions(destSize, YES, 1.0);
    
    float s = destSize.height / sz.width;
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -diffX, 0);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), s, s);
    [image drawInRect:CGRectMake(0, -cropRect.origin.y * 2.0 / s, sz.width, sz.height)];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
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
 
    [[self dimensionLabel] setFont:STKFont(11)];
}

- (CGRect)rectForCameraArea
{
    CGRect top = [[self topBar] frame];
    CGRect bottom = [[self bottomBar] frame];
    
    top = [[self view] convertRect:top fromView:[[self topBar] superview]];
    bottom = [[self view] convertRect:bottom fromView:[[self bottomBar] superview]];
    
    CGRect r = CGRectMake(0, top.origin.y + top.size.height, 320, bottom.origin.y);
    r = [[[self view] layer] convertRect:r toLayer:[[self captureView] videoLayer]];
 
    return r;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[[self session] inputs] count] > 0 && ![self capturedImage])
        [[self session] startRunning];

    if([self editingImage]) {
        [self setCapturedImage:[self editingImage]];
        [self prepareImageForEdit:[self capturedImage]];
    }

    [self configureInterface];

    [self configureOverlayView];
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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self setImageInfo:info];
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self setCapturedImage:img];
    
    [_capturedImageView removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self prepareImageForEdit:[self capturedImage]];
    }];
}

- (void)prepareImageForEdit:(UIImage *)img
{
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[self capturedImage]];
    CGSize sz = [[self capturedImage] size];
    
    float smallSide = sz.width;
    if(sz.height < smallSide)
        smallSide = sz.height;
    
    float scale = [[self editScrollView] bounds].size.width / smallSide;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    CGSize imageViewSize = sz;
    if(imageViewSize.width > imageViewSize.height) {
        float i = scale * -fabs(imageViewSize.width - imageViewSize.height) / 2.0;
        insets.top = i;
        insets.bottom = i;
        imageViewSize.height = imageViewSize.width;
    } else if(imageViewSize.height > imageViewSize.width){
        float i = scale * -fabs(imageViewSize.height - imageViewSize.width) / 2.0;
        insets.left = i;
        insets.right = i;
        imageViewSize.width = imageViewSize.height;
    }
    
    [newImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [[self editScrollView] addSubview:newImageView];
    [newImageView setContentMode:UIViewContentModeCenter];
    [newImageView setFrame:CGRectMake(0, 0, imageViewSize.width, imageViewSize.height)];
    _capturedImageView = newImageView;
    
    [[self editScrollView] setContentSize:imageViewSize];
    [[self editScrollView] setMinimumZoomScale:scale];
    [[self editScrollView] setZoomScale:scale];
    
    if([self type] == STKImageChooserTypeCover) {
        float coverInset = ([[self editScrollView] frame].size.height - STKUserCoverPhotoSize.height) / 2.0;
        insets.top += coverInset;
        insets.bottom += coverInset;
    }
    [[self editScrollView] setContentInset:insets];
    
    float centerDiffX = ceilf((imageViewSize.width * scale - [[self editScrollView] frame].size.width) / 2.0);
    float centerDiffY = ceilf((imageViewSize.height * scale  - [[self editScrollView] frame].size.height) / 2.0);
    
    [[self editScrollView] setContentOffset:CGPointMake(centerDiffX, centerDiffY)];
    
    [self setCroppingImage:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self capturedImageView];
}

// we need to know what orientation the user thinks they are in
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    [self setDeviceOrientation:[[UIDevice currentDevice] orientation]];
    return NO;
}

- (void)setDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    _deviceOrientation = deviceOrientation;
    
    if([self type] == STKImageChooserTypeCover) {
        [self configureOverlayView];
    }
}

- (UIImage *)updateImageToCurrentOrientation:(UIImage *)image
{
    if ([self deviceOrientation] == UIDeviceOrientationPortrait) {
        return image;
    }
    
    NSDictionary *map = @{@(UIDeviceOrientationLandscapeLeft) : @(UIImageOrientationLeft),
                          @(UIDeviceOrientationLandscapeRight) : @(UIImageOrientationRight),
                          @(UIDeviceOrientationPortraitUpsideDown) : @(UIImageOrientationDown)};
    
    return [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:[map[@([self deviceOrientation])] intValue]];
}

- (void)configureOverlayView
{
    if([self type] == STKImageChooserTypeProfile) {
        UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:CGRectInset([[self overlayView] bounds], 4, 4)];
        [[self overlayView] setCutPath:bp];
        [[self dimensionLabel] setText:@"256x256px"];
    } else if([self type] == STKImageChooserTypeCover) {
        float h = STKUserCoverPhotoSize.height;
        
        UIBezierPath *bp = nil;
        if (UIDeviceOrientationIsLandscape([self deviceOrientation])) {
            bp = [UIBezierPath bezierPathWithRect:CGRectMake((320.0 - h) / 2.0, 2, h, 316.0)];
        } else {
            bp = [UIBezierPath bezierPathWithRect:CGRectMake(2, (320.0 - h) / 2.0, 316.0, h)];
        }
        [[self overlayView] setCutPath:bp];
        
        [[self dimensionLabel] setText:@"640x376px"];
    } else {
        [[self overlayView] setCutPath:nil];
        [[self dimensionLabel] setText:@""];
    }
}

@end
