//
//  STKImageChooser.h
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKImageChooser : NSObject

+ (STKImageChooser *)sharedImageChooser;

- (void)initiateImageChooserForViewController:(UIViewController *)vc
                                   completion:(void (^)(UIImage *))block;


@end
