//
//  STKJSONObject.h
//
//  Created by Joe Conway on 2/25/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STKJSONObject <NSObject>

- (NSError *)readFromJSONObject:(id)jsonObject;

@end

@interface NSObject (STKJSONBind)

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
            destinationKey:(NSString *)destKey;

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
          destinationBlock:(void (^)(id destinationObject, id inVal))block;

- (void)bindFromDictionary:(NSDictionary *)dataDictionary
                    keyMap:(NSDictionary *)keyMap;

@end
