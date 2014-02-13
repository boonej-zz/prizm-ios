//
//  STKCaptureView.m
//  Prism
//
//  Created by Joe Conway on 1/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCaptureView.h"

@interface STKCaptureView ()
@end

@implementation STKCaptureView
@dynamic session;

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
    [self setClipsToBounds:YES];
    _videoLayer = [AVCaptureVideoPreviewLayer layer];
    [[self layer] addSublayer:_videoLayer];
    [_videoLayer setBounds:CGRectMake(0, 0, 320, 568)];
    [_videoLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_videoLayer setPosition:[self center]];

}

- (AVCaptureSession *)session
{
	return [(AVCaptureVideoPreviewLayer *)[self videoLayer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
	[(AVCaptureVideoPreviewLayer *)[self videoLayer] setSession:session];
}


@end
