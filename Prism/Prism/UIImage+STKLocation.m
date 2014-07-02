//
//  UIImage+STKLocation.m
//  Prism
//
//  Created by Jonathan Boone on 7/1/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "UIImage+STKLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@implementation UIImage (STKLocation)

+ (void)LocationCoordinateFromImageInfo:(NSDictionary *)imageInfo completion:(void(^)(NSError *, CLLocationCoordinate2D))completion
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block CLLocationCoordinate2D locationCoordinate;
    [library assetForURL:[imageInfo objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
        
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        uint8_t *buffer = (Byte *)malloc((uint)rep.size);
        NSError *lenErr = nil;
        NSUInteger length = [rep getBytes:buffer fromOffset:0.0 length:(uint)rep.size error:&lenErr];
        if (length != 0){
            NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:(uint)rep.size freeWhenDone:YES];
            NSDictionary *sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)[rep UTI], kCGImageSourceTypeIdentifierHint, nil];
            CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)sourceOptionsDict);
            CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
            CFDictionaryRef gps = (CFDictionaryRef)CFDictionaryGetValue(imageProperties, kCGImagePropertyGPSDictionary);
            NSNumber *latitude = CFDictionaryGetValue(gps, kCGImagePropertyGPSLatitude);
            NSNumber *longitude = CFDictionaryGetValue(gps, kCGImagePropertyGPSLongitude);
            NSString *latRef = CFDictionaryGetValue(gps, kCGImagePropertyGPSLatitudeRef);
            NSString *lonRef = CFDictionaryGetValue(gps, kCGImagePropertyGPSLongitudeRef);
            if ([latRef isEqualToString:@"S"]) {
                latitude = [NSNumber numberWithDouble:-[latitude doubleValue]];
            }
            if ([lonRef isEqualToString:@"W"]) {
                longitude = [NSNumber numberWithDouble:-[longitude doubleValue]];
            }
            locationCoordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        }
        completion(nil, locationCoordinate);
        
    } failureBlock:^(NSError *error) {
        completion(error, locationCoordinate);
    }];
}

@end
