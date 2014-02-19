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

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    
    [self setImage:nil];
    NSLog(@"%@", NSStringFromCGRect([self frame]));
    if(_urlString) {
        __weak STKResolvingImageView *iv = self;
        [[STKImageStore store] fetchImageForURLString:_urlString
                                           completion:^(UIImage *img) {
                                               if([urlString isEqualToString:[iv urlString]]) {
                                                   [iv setImage:img];
                                                   //[iv setNeedsDisplay];
                                               }
                                           }];
    }
    
}
@end
