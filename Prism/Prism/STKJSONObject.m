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
                  matchMap:(NSDictionary *)matchMap
{
    id value = [d valueForKeyPath:sourceKey];
    if(!value)
        return;
    if([value isKindOfClass:[NSNull class]])
        return;
    
    if([self isKindOfClass:[NSManagedObject class]]) {
        // Is this a relationship?

        NSDictionary *relationships = [[(NSManagedObject *)self entity] relationshipsByName];
        NSRelationshipDescription *relationship = [relationships objectForKey:destKey];
        if(relationship) {
            
            if([value isKindOfClass:[NSArray class]]) {
                for(NSDictionary *d in value) {
                    [self createOrInsertJSONObject:d forRelationship:relationship matchMap:matchMap];
                }
            } else {
                [self createOrInsertJSONObject:value forRelationship:relationship matchMap:matchMap];
            }
            return;
        }
    }
    
    [self setValue:value forKey:destKey];
}

- (void)bindFromDictionary:(NSDictionary *)d
                 sourceKey:(NSString *)sourceKey
  destinationConfiguration:(NSDictionary *)config
{
    id value = [d valueForKeyPath:sourceKey];
    if(!value)
        return;
    if([value isKindOfClass:[NSNull class]])
        return;
    
    if([self isKindOfClass:[NSManagedObject class]]) {
        // Is this a relationship?
        
        NSDictionary *relationships = [[(NSManagedObject *)self entity] relationshipsByName];
        NSRelationshipDescription *relationship = [relationships objectForKey:[config objectForKey:@"key"]];
        if(relationship) {
            
            if([value isKindOfClass:[NSArray class]]) {
                for(NSDictionary *d in value) {
                    [self createOrInsertJSONObject:d forRelationship:relationship matchMap:[config objectForKey:@"match"]];
                }
            } else {
                [self createOrInsertJSONObject:value forRelationship:relationship matchMap:[config objectForKey:@"match"]];
            }
            return;
        }
    }
    
    [self setValue:value forKey:[config objectForKey:@"key"]];
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
             
        } else {
            [self bindFromDictionary:dataDictionary
                           sourceKey:key
                    destinationBlock:value];
        }
    }
}

@end
