//
//  STKTimestampFormatter.h
//  Prism
//
//  Created by Joe Conway on 4/16/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKTimestampFormatter : NSObject

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)string;

@end
