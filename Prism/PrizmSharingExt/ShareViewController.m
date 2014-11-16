//
//  ShareViewController.m
//  PrizmSharingExt
//
//  Created by Eric Kenny on 11/16/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "ShareViewController.h"


@interface ShareViewController ()

//@property (nonatomic, strong) UIImage *postImage;

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSExtensionItem *postImageItem = [[[self extensionContext] inputItems] firstObject];
    if (!postImageItem) {
        return;
    }
    
    NSItemProvider *postImageItemProvider = [[postImageItem attachments] firstObject];
    if (!postImageItemProvider) {
        return;
    }
    
    if ([postImageItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        [postImageItemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^
         (UIImage *image, NSError *error) {
             if (image) {
                 self.postImage = image;
             }
         }];
    }
    
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
