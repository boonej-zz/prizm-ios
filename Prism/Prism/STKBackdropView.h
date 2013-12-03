//
//  STKBackdropView.h
//  Prism
//
//  Created by Joe Conway on 12/3/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKBackdropView : UIView

- (id)initWithFrame:(CGRect)frame relativeTo:(UIView *)blurView;

@property (nonatomic, strong) UIColor *blurBackgroundColor;
@property (nonatomic, strong) UIImage *blurBackgroundImage;

- (BOOL)shouldBlurImageForIndexPath:(NSIndexPath *)ip;
- (void)addBlurredImage:(UIImage *)image
                forRect:(CGRect)rect
              indexPath:(NSIndexPath *)ip;
- (void)invalidateCache;

@end
