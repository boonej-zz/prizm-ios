//
//  STKRelativeDateConverter.m
//  Prism
//
//  Created by Joe Conway on 1/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKRelativeDateConverter.h"

@implementation STKRelativeDateConverter

+ (NSString *)relativeDateStringFromDate:(NSDate *)date
{
    NSTimeInterval i = -[date timeIntervalSinceNow];
    
    if(i < 60)
        return @"Now";
    
    if(i <= 3600) {
        int mins = i / 60;
        return [NSString stringWithFormat:@"%dm", mins];
    }
    
    if(i < 60 * 60 * 24) {
        int hours = i / (60 * 60);
        return [NSString stringWithFormat:@"%dh", hours];
    }
    
    int days = i / (60 * 60 * 24);
    if(days < 7) {
        return [NSString stringWithFormat:@"%dd", days];
    }
    
    return [NSString stringWithFormat:@"%dw", days / 7];
}

@end
