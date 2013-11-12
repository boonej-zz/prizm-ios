//
//  STKJSONObject.m
//  Rheem EcoNet
//
//  Created by Joe Conway on 2/25/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//
#import "STKJSONObject.h"

@implementation NSObject (STKJSONBind)

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
            destinationKey:(NSString *)destKey
{
    id value = [d objectForKey:sourceKey];
    if(!value)
        return;
    if([value isKindOfClass:[NSNull class]])
        return;
    
    [self setValue:value forKey:destKey];
}

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
          destinationBlock:(void (^)(id destinationObject, id inVal))block
{
    id value = [d objectForKey:sourceKey];
    if(!value)
        return;
    if([value isKindOfClass:[NSNull class]])
        return;

    block(self, value);
}

- (void)bindFromDictionary:(NSDictionary *)dataDictionary
                    keyMap:(NSDictionary *)keyMap
{
    for(NSString *key in keyMap) {
        id value = [keyMap objectForKey:key];
        if([value isKindOfClass:[NSString class]]) {
            [self bindFromDictionary:dataDictionary
                           sourceKey:key
                      destinationKey:value];
        } else {
            [self bindFromDictionary:dataDictionary
                           sourceKey:key
                    destinationBlock:value];
        }
    }
}

@end
