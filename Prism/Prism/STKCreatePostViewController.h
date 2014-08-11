//
//  STKCreatePostViewController.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKPost;

@interface STKCreatePostViewController : UIViewController

@property (nonatomic, weak) STKPost *originalPost;

- (void)setPostImage:(UIImage *)postImage;

@end
