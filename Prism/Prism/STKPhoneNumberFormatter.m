//
//  STKPhoneNumberFormatter.m
//  Prism
//
//  Created by Joe Conway on 7/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPhoneNumberFormatter.h"

// This is a very bullshit implementation that is not robust but solves a specific problem

@implementation STKPhoneNumberFormatter
- (NSString *)stringForObjectValue:(id)obj
{
    if(![obj isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *currentString = (NSString *)obj;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]" options:0 error:nil];
    currentString = [regex stringByReplacingMatchesInString:currentString options:0 range:NSMakeRange(0, [currentString length]) withTemplate:@""];
    // Strip non-numerals
    
    if([currentString length] <= 2) {
        return currentString;
    } else if([currentString length] == 3) {
        return [NSString stringWithFormat:@"(%@)", currentString];
    } else if ([currentString length] <= 6) {
        NSString *areaCode = [currentString substringToIndex:3];
        NSString *front = [currentString substringFromIndex:3];
        return [NSString stringWithFormat:@"(%@) %@", areaCode, front];
    } else {
        NSString *areaCode = [currentString substringToIndex:3];
        NSString *remaining = [currentString substringFromIndex:3];
        NSString *front = [remaining substringToIndex:3];
        NSString *back = [remaining substringFromIndex:3];
        if([back length] > 4) {
            back = [back substringToIndex:4];
        }
        return [NSString stringWithFormat:@"(%@) %@-%@", areaCode, front, back];

    }
    return obj;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
    if(anObject) {
        *anObject = string;
    }
    return YES;
}
@end
