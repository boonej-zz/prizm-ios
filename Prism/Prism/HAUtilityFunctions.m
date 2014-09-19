//
//  HAUtilityFunctions.m
//  Prizm
//
//  Created by Jonathan Boone on 8/21/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAUtilityFunctions.h"
#import "STKUserStore.h"
#import "STKUser.h"

NSDictionary * mixpanelDataForObject(id obj)
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d addEntriesFromDictionary:[[[STKUserStore store] currentUser] mixpanelProperties]];
    NSDictionary *p = nil;
    if (obj) {
        if ([obj isKindOfClass:[NSDictionary class]]){
            p = obj;
        } else if ([obj respondsToSelector:@selector(mixpanelProperties)]){
            p = [obj mixpanelProperties];
        }
        [d addEntriesFromDictionary:p];
    }
    return [d copy];
}

CGPoint randomPointWithinContainer(CGSize containerSize, CGSize viewSize) {
    CGFloat xRange = containerSize.width - viewSize.width;
    CGFloat yRange = containerSize.height - viewSize.height;
    
    CGFloat minX = (containerSize.width - xRange) / 2;
    CGFloat minY = (containerSize.height - yRange) / 2;
    
    int randomX = (arc4random() % (int)floorf(xRange)) + minX;
    int randomY = (arc4random() % (int)floorf(yRange)) + minY;
    return CGPointMake(randomX, randomY);
}
