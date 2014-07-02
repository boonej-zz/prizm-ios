//
//  UIImage+STKLocation.h
//  Prism
//
//  Created by Jonathan Boone on 7/1/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface UIImage (STKLocation)

/**
 Pulls GPS Coordinates from image info dictionary.
 */
+ (void)LocationCoordinateFromImageInfo:(NSDictionary *)imageInfo completion:(void(^)(NSError *, CLLocationCoordinate2D))completion;

@end
