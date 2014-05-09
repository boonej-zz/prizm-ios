//
//  STKAuthorizationToken.m
//  Prism
//
//  Created by Joe Conway on 2/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKAuthorizationToken.h"

@implementation STKAuthorizationToken

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject
                      keyMap:
    @{
        @"access_token" : @"accessToken",
        @"refresh_token": @"refreshToken",
        @"token_type" : @"tokenType",
        @"expires_in" : [STKBind bindMapForKey:@"expiration" transform:^id(id inValue, STKTransformDirection direction) {
            float timeDelta = [inValue floatValue];
            return [NSDate dateWithTimeIntervalSinceNow:timeDelta];
        }]
    }];
    return nil;
}

@end
