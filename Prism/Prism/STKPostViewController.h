//
//  STKPostViewController.h
//  Prism
//
//  Created by Joe Conway on 1/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKPost, STKPostViewController, STKProfile;


@protocol STKPostViewControllerDelegate <NSObject>

- (void)postViewController:(STKPostViewController *)postViewController
          didSelectProfile:(STKProfile *)profile;

@end

@interface STKPostViewController : UIViewController

@property (nonatomic, strong) STKPost *post;

@end
