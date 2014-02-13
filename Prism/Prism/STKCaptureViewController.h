//
//  STKCaptureViewController.h
//  Prism
//
//  Created by Joe Conway on 1/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKImageChooser.h"

@class STKCaptureViewController;

@protocol STKCaptureViewControllerDelegate <NSObject>

- (void)captureViewController:(STKCaptureViewController *)captureViewController
                 didPickImage:(UIImage *)image;

@end

@interface STKCaptureViewController : UIViewController

@property (nonatomic, weak) id <STKCaptureViewControllerDelegate> delegate;
@property (nonatomic) STKImageChooserType type;

- (IBAction)showLibrary:(id)sender;

@end
