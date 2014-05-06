//
//  STKBindTransforms.m
//  Prism
//
//  Created by Joe Conway on 5/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKBindTransforms.h"
#import "STKTimestampFormatter.h"

STKTransformBlock STKBindTransformDateTimestamp = ^id(id inValue, STKTransformDirection direction) {
    if(direction == STKTransformDirectionLocalToRemote) {
        return [STKTimestampFormatter stringFromDate:inValue];
    } else {
        return [STKTimestampFormatter dateFromString:inValue];
    }
};
