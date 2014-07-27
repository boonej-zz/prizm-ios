//
//  STKMessageBanner.h
//  Prism
//
//  Created by DJ HAYDEN on 7/21/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    STKMessageBannerTypeError = 0,  //red
    STKMessageBannerTypeWarning,    //yellow
    STKMessageBannerTypeSuccess,    //green
    STKMessageBannerTypeNotify      //orange
} STKMessageBannerType;

extern CGFloat const STKMessageBannerHeight;

@interface STKMessageBanner : UIView
@property (nonatomic, getter = isVisible) BOOL visible;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, assign) STKMessageBannerType type;

@end
