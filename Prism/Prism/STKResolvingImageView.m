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
    [self setPreferredSize:STKImageStoreThumbnailNone];
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    
    [self setImage:nil];

    if(_urlString) {
        __weak STKResolvingImageView *iv = self;
        [[STKImageStore store] fetchImageForURLString:_urlString
                                        preferredSize:[self preferredSize]
                                           completion:^(UIImage *img) {
                                               if([urlString isEqualToString:[iv urlString]]) {
                                                   [iv setImage:img];
                                                   if([self imageResolvedCompletion]) {
                                                       [self imageResolvedCompletion](img != nil);
                                                   }
                                                   //[iv setNeedsDisplay];
                                               }
                                           }];
    }
    
}
@end
