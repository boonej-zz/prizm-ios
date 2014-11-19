//
//  ShareViewController.m
//  PrizmShareExt
//
//  Created by Eric Kenny on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "ShareViewController.h"


@interface ShareViewController ()

@property (nonatomic, strong) UIImage *postImage;

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    NSExtensionItem *imageItem = [self.extensionContext.inputItems firstObject];
    if (!imageItem) {
        return;
    }
    
    NSItemProvider *imageItemProvider = [[imageItem attachments] firstObject];
    if (!imageItemProvider) {
        return;
    }
    
    if ([imageItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        
        [imageItemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
            
            if(image){

                UIImage *croppedImage = [self cropImage:image];
                [self savePostToUserDefaults:self.contentText withImage:croppedImage];
                [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
            }
        }];
        
    }
    
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.

}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

- (NSUserDefaults *)savePostToUserDefaults:(NSString *)postText withImage:(UIImage *)postImage
{
    NSUserDefaults *sharedPost = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.higheraltitude.prizm.staging"];

    [sharedPost setObject:postText forKey:@"postText"];
    [sharedPost setObject:UIImageJPEGRepresentation(postImage, 1.0) forKey:@"postImage"];
    return sharedPost;
}

- (UIImage *)cropImage:(UIImage *)image
{
    CGSize newSize = CGSizeMake(600, 600);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
