//
//  STKImageSharer.h
//  Prism
//
//  Created by Joe Conway on 3/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const STKActivityTypeInstagram;
extern NSString * const STKActivityTypeTumblr;
extern NSString * const STKActivityTypeWhatsapp;

@class STKPost;

@interface STKImageSharer : NSObject

+ (STKImageSharer *)defaultSharer;


- (UIActivityViewController *)activityViewControllerForPost:(STKPost *)post
                                              finishHandler:(void (^)(UIDocumentInteractionController *))block;
- (NSArray *)activitiesForImage:(UIImage *)image title:(NSString *)title viewController:(UIViewController *)viewController;
@end
