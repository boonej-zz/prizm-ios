//
//  STKCaptureView.h
//  Prism
//
//  Created by Joe Conway on 1/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@interface STKCaptureView : UIControl

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *videoLayer;

@end
