//
//  STKBindTransforms.h
//  Prism
//
//  Created by Joe Conway on 5/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    STKTransformDirectionLocalToRemote,
    STKTransformDirectionRemoteToLocal
} STKTransformDirection;

typedef id (^STKTransformBlock)(id inValue, STKTransformDirection direction);

extern STKTransformBlock STKBindTransformDateTimestamp;