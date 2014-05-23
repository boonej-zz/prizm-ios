//
//  STKLuminatingBar.h
//  Prism
//
//  Created by Joe Conway on 5/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKLuminatingBar : UIView
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic) BOOL luminating;
@property (nonatomic) float progress;
@property (nonatomic) float luminationOpacity;
@end
