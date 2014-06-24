//
//  STKImageSharer.h
//  Prism
//
//  Created by Joe Conway on 3/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKPost;

@interface STKImageSharer : NSObject

+ (STKImageSharer *)defaultSharer;


- (UIActivityViewController *)activityViewControllerForPost:(STKPost *)post
                                              finishHandler:(void (^)(UIDocumentInteractionController *))block;
- (NSArray *)activitiesForImage:(UIImage *)image title:(NSString *)title;

@end

@class STKActivity;

@protocol STKActivityDelegate <NSObject>

- (void)activity:(STKActivity *)activity
wantsToPresentDocumentController:(UIDocumentInteractionController *)doc;

@end

@interface STKActivity : UIActivity

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, weak) id <STKActivityDelegate> delegate;

- (id)initWithDelegate:(id <STKActivityDelegate>)delegate;

@end
