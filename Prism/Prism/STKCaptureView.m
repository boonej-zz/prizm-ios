//
//  STKCaptureView.m
//  Prism
//
//  Created by Joe Conway on 1/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCaptureView.h"

@implementation STKCaptureView
@dynamic session;

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
//    [self setClipsToBounds:YES];
    [(AVCaptureVideoPreviewLayer *)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
}

- (AVCaptureSession *)session
{
	return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
	[(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}


@end
