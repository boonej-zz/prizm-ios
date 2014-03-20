//
//  STKAvatarView.h
//  Prism
//
//  Created by Joe Conway on 3/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKResolvingImageView.h"

@interface STKAvatarView : UIView

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *overlayColor;

@property (nonatomic) CGFloat outlineWidth;
@property (nonatomic, strong) UIColor *outlineColor;

@end
