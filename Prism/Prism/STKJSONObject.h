//
//  STKJSONObject.h
//
//  Created by Joe Conway on 2/25/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const STKJSONBindFieldKey;
extern NSString * const STKJSONBindMatchDictionaryKey;
extern NSString * const STKJSONBindFunctionKey;
    extern NSString * const STKJSONBindFunctionReplace; // Default
    extern NSString * const STKJSONBindFunctionAdd;

@protocol STKJSONObject <NSObject>

- (NSError *)readFromJSONObject:(id)jsonObject;

@end

@interface NSObject (STKJSONBind)

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
            destinationKey:(NSString *)destKey
                  matchMap:(NSDictionary *)matchMap;

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
          destinationBlock:(void (^)(id inVal))block;

- (void)bindFromDictionary:(NSDictionary *)dataDictionary
                    keyMap:(NSDictionary *)keyMap;

+ (NSDictionary *)inboundKeyMap;
+ (NSDictionary *)outboundKeyMap;

@end
