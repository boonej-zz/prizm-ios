//
//  STKJSONObject.h
//
//  Created by Joe Conway on 2/25/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STKBindTransforms.h"


extern NSString * const STKJSONBindFieldKey;
extern NSString * const STKJSONBindMatchDictionaryKey;
extern NSString * const STKJSONBindTransformKey;
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

- (void)bindFromDictionary:(NSDictionary *)dataDictionary
                    keyMap:(NSDictionary *)keyMap;


+ (NSDictionary *)remoteToLocalKeyMap;

+ (NSString *)remoteKeyForLocalKey:(NSString *)localKey;
+ (NSString *)localKeyForRemoteKey:(NSString *)remoteKey;

- (id)remoteValueForLocalKey:(NSString *)localKey;
- (NSDictionary *)remoteValueMapForLocalKeys:(NSArray *)localKeys;

@end

@interface STKBind : NSObject

+ (NSDictionary *)bindMapForKey:(NSString *)fieldKey matchMap:(NSDictionary *)matchMap;
+ (NSDictionary *)bindMapForKey:(NSString *)fieldKey
                      transform:(STKTransformBlock)transform;

@end
