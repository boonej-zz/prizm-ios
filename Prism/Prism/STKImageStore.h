//
//  STKImageStore.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    STKImageStoreThumbnailNone,
    STKImageStoreThumbnailLarge,
    STKImageStoreThumbnailMedium,
    STKImageStoreThumbnailSmall
} STKImageStoreThumbnail;

@interface STKImageStore : NSObject

+ (STKImageStore *)store;

// Returns YES if the block was run immediately and only that the block was run immediately.
// If a web service request was fired, which means the block won't run for some time interval, this returns NO.
// The return value of this method signifies nothing about the image being available/returned/valid.
- (BOOL)fetchImageForURLString:(NSString *)url completion:(void (^)(UIImage *img))block;

- (void)fetchImageForURLString:(NSString *)url preferredSize:(STKImageStoreThumbnail)size completion:(void (^)(UIImage *img))block;

- (void)uploadImage:(UIImage *)image
      intoDirectory:(NSString *)directory
         completion:(void (^)(NSString *URLString, NSError *err))block;

- (void)uploadImage:(UIImage *)image
     thumbnailCount:(int)thumbnailCount
      intoDirectory:(NSString *)directory
         completion:(void (^)(NSString *URLString, NSError *err))block;


- (UIImage *)cachedImageForURLString:(NSString *)url;
- (UIImage *)bestCachedImageForURLString:(NSString *)url;
- (void)deleteCachedImagesForURLString:(NSString *)url;
- (void)deleteAllCachedImages;

@end
