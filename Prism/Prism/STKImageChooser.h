//
//  STKImageChooser.h
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    STKImageChooserTypeImage,
    STKImageChooserTypeProfile,
    STKImageChooserTypeCover
} STKImageChooserType;

@interface STKImageChooser : NSObject

+ (STKImageChooser *)sharedImageChooser;

- (void)initiateImageChooserForViewController:(UIViewController *)vc
                                      forType:(STKImageChooserType)type
                                   completion:(void (^)(UIImage *, UIImage *, NSDictionary *))block;

- (void)initiateImageEditorForViewController:(UIViewController *)vc
                                     forType:(STKImageChooserType)type
                                       image:(UIImage *)image
                                  completion:(void (^)(UIImage *, UIImage *, NSDictionary *))block;


@end
