//
//  UITextView+STKHashtagDetector.h
//  Prism
//
//  Created by Jesse Stevens Black on 12/1/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (STKHashtagDetector)

- (NSRange)rangeOfCurrentWord;
- (NSString *)currentHashtag;

- (void)formatHashtags;

@end
