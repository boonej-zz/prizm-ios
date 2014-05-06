//
//  STKJSONObject.m
//  Rheem EcoNet
//
//  Created by Joe Conway on 2/25/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//
#import "STKJSONObject.h"

NSString * const STKJSONBindFieldKey = @"key";
NSString * const STKJSONBindMatchDictionaryKey = @"match";
NSString * const STKJSONBindFunctionKey = @"func";
NSString * const STKJSONBindFunctionReplace = @"replace";
NSString * const STKJSONBindFunctionAdd = @"add";
NSString * const STKJSONBindTransformKey = @"transform";

@implementation NSObject (STKJSONBind)


+ (NSString *)remoteKeyForLocalKey:(NSString *)localKey
{
    NSDictionary *map = [self remoteToLocalKeyMap];
    for(NSString *remoteKey in map) {
        id value = [map objectForKey:remoteKey];
        if([value isKindOfClass:[NSString class]]) {
            if([value isEqualToString:localKey])
                return value;
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            if([[value objectForKey:STKJSONBindFieldKey] isEqualToString:localKey]) {
                return [value objectForKey:STKJSONBindFieldKey];
            }
        }
    }
    return nil;
}

+ (NSString *)localKeyForRemoteKey:(NSString *)remoteKey
{
    id value = [[self remoteToLocalKeyMap] objectForKey:remoteKey];
    if([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        return [value objectForKey:STKJSONBindFieldKey];
    }
    return nil;
}

- (id)remoteValueForLocalKey:(NSString *)localKey
{
    NSDictionary *map = [[self class] remoteToLocalKeyMap];
    for(NSString *remoteKey in map) {
        id value = [map objectForKey:remoteKey];
        if(!value || [value isKindOfClass:[NSNull class]])
            return [NSNull null];
        
        if([value isKindOfClass:[NSString class]]) {
            return [self valueForKeyPath:localKey];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            STKTransformBlock transform = [value objectForKey:STKJSONBindTransformKey];
            if(transform)
                return transform([self valueForKeyPath:localKey], STKTransformDirectionLocalToRemote);
            else {
                return [self valueForKeyPath:localKey];
            }
        }
    }
    return [NSNull null];
}

- (NSDictionary *)remoteValueMapForLocalKeys:(NSArray *)localKeys
{
    NSDictionary *map = [[self class] remoteToLocalKeyMap];
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    for(NSString *remoteKey in map) {
        NSString *localKey = nil;
        id mapVal = [map objectForKey:remoteKey];
        
        if([mapVal isKindOfClass:[NSString class]]) {
            localKey = mapVal;
        } else if([mapVal isKindOfClass:[NSDictionary class]]) {
            localKey = [mapVal objectForKey:STKJSONBindFieldKey];
        }
        
        if([localKeys containsObject:localKey]) {
            
            id outputValue = [self valueForKeyPath:localKey];
            if([mapVal isKindOfClass:[NSDictionary class]]) {
                STKTransformBlock transform = [mapVal objectForKey:STKJSONBindTransformKey];
                if(transform) {
                    outputValue = transform(outputValue, STKTransformDirectionLocalToRemote);
                }
            }
            [output setObject:outputValue forKey:remoteKey];
        }
    }
    
    return output;
}


+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{};
}


- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
            destinationKey:(NSString *)destKey
                  matchMap:(NSDictionary *)matchMap
{
    id value = [d valueForKeyPath:sourceKey];
    if(!value)
        return;
    
    if([value isKindOfClass:[NSNull class]]) {
        [self setValue:nil forKeyPath:destKey];
    } else {
        [self setValue:value forKey:destKey];
    }
}

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
  destinationConfiguration:(NSDictionary *)config
{
    id value = [d valueForKeyPath:sourceKey];
    if(!value)
        return;
    
    NSString *fieldKey = [config objectForKey:STKJSONBindFieldKey];
    
    if([value isKindOfClass:[NSNull class]]) {
        [self setValue:nil forKeyPath:fieldKey];
    } else {
        
        STKTransformBlock transform = [config objectForKey:STKJSONBindTransformKey];
        if(transform) {
            value = transform(value, STKTransformDirectionRemoteToLocal);
        }
        
        if([self isKindOfClass:[NSManagedObject class]]) {
            // Is this a relationship?
            
            NSDictionary *relationships = [[(NSManagedObject *)self entity] relationshipsByName];
            NSRelationshipDescription *relationship = [relationships objectForKey:[config objectForKey:@"key"]];
            if(relationship) {
                if([value isKindOfClass:[NSArray class]]) {
                    NSString *bindFunction = STKJSONBindFunctionReplace;
                    if([config objectForKey:STKJSONBindFunctionKey]) {
                        bindFunction = [config objectForKey:STKJSONBindFunctionKey];
                    }
                    
                    // If the bind function is replace, kill the existing
                    if([bindFunction isEqualToString:STKJSONBindFunctionReplace]) {
                        [(NSManagedObject *)self setValue:nil forKey:[relationship name]];
                    }
                    
                    for(NSDictionary *d in value) {
                        [self createOrInsertJSONObject:d forRelationship:relationship matchMap:[config objectForKey:@"match"]];
                    }
                } else {
                    [self createOrInsertJSONObject:value forRelationship:relationship matchMap:[config objectForKey:@"match"]];
                }
                return;
            }
        }
        
        [self setValue:value forKey:fieldKey];
    }
}


/*
- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
          destinationBlock:(void (^)(id inVal))block
{
    id value = [d valueForKeyPath:sourceKey];
    if(!value)
        return;
    if([value isKindOfClass:[NSNull class]])
        return;

    block(value);
}
*/
- (void)bindFromDictionary:(NSDictionary *)dataDictionary
                    keyMap:(NSDictionary *)keyMap
{
    for(NSString *key in keyMap) {
        id value = [keyMap objectForKey:key];
        if([value isKindOfClass:[NSString class]]) {
            [self bindFromDictionary:dataDictionary
                           sourceKey:key
                      destinationKey:value
                            matchMap:nil];
        } else if([value isKindOfClass:[NSDictionary class]]) {
            [self bindFromDictionary:dataDictionary
                           sourceKey:key
            destinationConfiguration:value];
             
        }
    }
}

- (void)createOrInsertJSONObject:(NSDictionary *)jsonObject
                 forRelationship:(NSRelationshipDescription *)relationship
                        matchMap:(NSDictionary *)matchMap
{
    NSManagedObject *mSelf = (NSManagedObject *)self;
    
    NSManagedObject <STKJSONObject> *obj = [[mSelf managedObjectContext] instanceForEntityName:[[relationship destinationEntity] name]
                                                                                        object:jsonObject
                                                                                      matchMap:matchMap
                                                                                 alreadyExists:nil];
    [obj readFromJSONObject:jsonObject];
    
    if([relationship isToMany]) {
        if(![[mSelf valueForKey:[relationship name]] containsObject:obj]) {
            if([relationship isOrdered]) {
                [[mSelf mutableOrderedSetValueForKeyPath:[relationship name]] addObject:obj];
            } else {
                [[mSelf mutableSetValueForKeyPath:[relationship name]] addObject:obj];
            }
        }
    } else {
        id value = [mSelf valueForKey:[relationship name]];
        if(![value isEqual:obj]) {
            [mSelf setValue:obj forKey:[relationship name]];
        }
    }
}

@end


@implementation STKBind

+ (NSDictionary *)bindMapForKey:(NSString *)fieldKey matchMap:(NSDictionary *)matchMap
{
    return @{STKJSONBindFieldKey : fieldKey, STKJSONBindMatchDictionaryKey : matchMap};
}

+ (NSDictionary *)bindMapForKey:(NSString *)fieldKey
                      transform:(STKTransformBlock)transform
{
    return @{STKJSONBindFieldKey : fieldKey, STKJSONBindTransformKey : transform};

}



@end
