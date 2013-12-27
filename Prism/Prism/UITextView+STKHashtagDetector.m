//
//  UITextView+STKHashtagDetector.m
//  Prism
//
//  Created by Jesse Stevens Black on 12/1/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "UITextView+STKHashtagDetector.h"

@implementation UITextView (STKHashtagDetector)

- (NSRange)rangeOfCurrentWord
{
    return [self rangeOfCurrentWordWithSelectedRange:self.selectedRange];
}

- (NSString *)currentHashtag
{
    return [self currentHashtagWithSelectedRange:self.selectedRange];
}

- (NSRange)rangeOfCurrentWordWithSelectedRange:(NSRange)range
{
    NSUInteger previousWhitespaceIndex = [self.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                                                             options:NSBackwardsSearch
                                                               range:NSMakeRange(0, range.location)].location;
    NSUInteger nextWhitespaceIndex = [self.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                                                         options:kNilOptions
                                                           range:NSMakeRange(range.location, self.text.length-range.location)].location;
    if (previousWhitespaceIndex == NSNotFound)  {
        return NSMakeRange(NSNotFound, 0);
    }
    if (nextWhitespaceIndex == NSNotFound)  {
        return NSMakeRange(NSNotFound, 0);
    }
    return NSMakeRange(previousWhitespaceIndex+1, nextWhitespaceIndex-previousWhitespaceIndex-1);
}

- (NSString *)currentHashtagWithSelectedRange:(NSRange)range
{
    NSRange wordRange = [self rangeOfCurrentWordWithSelectedRange:range];
    if (wordRange.length > 1)   {
        NSString *currentWord = [self.text substringWithRange:wordRange];
        if ([currentWord characterAtIndex:0] == '#')    {
            NSString *postTag = [currentWord substringFromIndex:1];
            if ([postTag rangeOfString:@"#"].location == NSNotFound)  {
                return postTag;
            }
        }
    }
    return nil;
}

- (NSArray *)hashtags
{
    NSMutableArray *hashtags = [NSMutableArray array];
    NSRange range;
    range.location = 0;
    range.length = 0;
    while (range.location != NSNotFound)    {
        NSUInteger location = range.length+range.location;
        range = [self.text rangeOfString:@"#" options:kNilOptions range:NSMakeRange(location,self.text.length-location)];
        if (range.location != NSNotFound)   {
            NSString *hashtag = [self currentHashtagWithSelectedRange:range];
            if (hashtag)    {
                [hashtags addObject:hashtag];
            }
        }
    }
    
    if (hashtags.count) {
        return hashtags;
    }
    
    return nil;
}

- (void)formatHashtags
{
    NSString *text = self.text;
    
    NSMutableArray *hashtagRanges = [NSMutableArray array];
    NSArray *hashtags = [self hashtags];
    NSLog(@"hashtags %@", hashtags);
    NSRange lastHashtagRange = NSMakeRange(0,0);
    for (NSString *hashtag in hashtags) {
        NSUInteger searchLocation = lastHashtagRange.length+lastHashtagRange.location;
        NSRange searchRange = NSMakeRange(searchLocation, text.length-searchLocation);
        NSRange hashtagRange = [text rangeOfString:hashtag options:kNilOptions range:searchRange];
        
        [hashtagRanges addObject:[NSValue valueWithRange:hashtagRange]];
        NSUInteger lastHashtagLocation = hashtagRange.location+hashtagRange.length;
        lastHashtagRange = NSMakeRange(lastHashtagLocation, 0);
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                       attributes:@{
                                                                                                    NSForegroundColorAttributeName: [UIColor darkTextColor
                                                                                                                                     ]}];

    for (NSValue *v in hashtagRanges)    {
        NSRange range = v.rangeValue;
        NSString *string = [text substringWithRange:range];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                               attributes:@{
                                                                                            NSForegroundColorAttributeName:[UIColor purpleColor]
                                                                                            }];
        [attributedText replaceCharactersInRange:range withAttributedString:attributedString];
    }

    [self setAttributedText:attributedText];
}

@end
