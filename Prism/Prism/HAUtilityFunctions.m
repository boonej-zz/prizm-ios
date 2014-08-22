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
