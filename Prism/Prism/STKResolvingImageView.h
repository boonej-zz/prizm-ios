//
//  STKResolvingImageView.h
//  Prism
//
//  Created by Joe Conway on 11/21/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKImageStore.h"

@interface STKResolvingImageView : UIImageView

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic) STKImageStoreThumbnail preferredSize;
@property (nonatomic, strong) UIImage *loadingImage;

@property (nonatomic) UIViewContentMode normalContentMode;
@property (nonatomic) UIViewContentMode loadingContentMode;

// Only pass weak references to parent object!
@property (nonatomic, strong) void (^imageResolvedCompletion)(BOOL success);

@end
