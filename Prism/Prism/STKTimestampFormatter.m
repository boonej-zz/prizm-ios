//
//  STKTimestampFormatter.m
//  Prism
//
//  Created by Joe Conway on 4/16/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTimestampFormatter.h"

@implementation STKTimestampFormatter

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *STKTimestampDateFormatter = nil;
    if(!STKTimestampDateFormatter) {
        STKTimestampDateFormatter = [[NSDateFormatter alloc] init];
        [STKTimestampDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [STKTimestampDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return STKTimestampDateFormatter;
}



+ (NSString *)stringFromDate:(NSDate *)date
{
    return [[self dateFormatter] stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string
{
    return [[self dateFormatter] dateFromString:string];
}

@end
