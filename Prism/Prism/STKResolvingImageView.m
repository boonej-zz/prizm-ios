//
//  STKResolvingImageView.m
//  Prism
//
//  Created by Joe Conway on 11/21/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKResolvingImageView.h"
#import "STKImageStore.h"

@implementation STKResolvingImageView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setNormalContentMode:[self contentMode]];
    [self setLoadingContentMode:[self contentMode]];
    [self setPreferredSize:STKImageStoreThumbnailNone];
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    
    if(urlString) {
        [self setImage:[self loadingImage]];
        [self setContentMode:[self loadingContentMode]];
    } else {
        [self setImage:nil];
    }
    
    if(_urlString) {
        __weak STKResolvingImageView *iv = self;
        [[STKImageStore store] fetchImageForURLString:_urlString
                                        preferredSize:[self preferredSize]
                                           completion:^(UIImage *img) {
                                               if([urlString isEqualToString:[iv urlString]]) {
                                                   [iv setContentMode:[self normalContentMode]];
                                                   [iv setImage:img];
                                                   if([self imageResolvedCompletion]) {
                                                       [self imageResolvedCompletion](img != nil);
                                                   }
                                               }
                                           }];
    }
    
}
@end
