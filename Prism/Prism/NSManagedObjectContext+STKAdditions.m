//
//  NSManagedObjectContext+STKAdditions.m
//  Prism
//
//  Created by Joe Conway on 3/26/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "NSManagedObjectContext+STKAdditions.h"

@implementation NSManagedObjectContext (STKAdditions)

- (NSManagedObject <STKJSONObject> *)instanceForEntityName:(NSString *)entityName
                                              sourceObject:(id)sourceObject
                                                  matchMap:(NSDictionary *)matchMap
                                             alreadyExists:(BOOL *)alreadyExists
{
    id obj = nil;
    if(matchMap) {
        NSMutableArray *predicates = [NSMutableArray array];
        for(NSString *localKey in matchMap) {
            NSPredicate *p = nil;
            if([sourceObject isKindOfClass:[NSString class]]) {
                p = [NSPredicate predicateWithFormat:@"%K == %@", localKey, sourceObject];
            } else {
                NSString *remoteKey = [matchMap objectForKey:localKey];
                p = [NSPredicate predicateWithFormat:@"%K == %@", localKey, [sourceObject valueForKeyPath:remoteKey]];
            }
            [predicates addObject:p];
        }
        NSPredicate *p = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [req setPredicate:p];
        
        NSArray *results = [self executeFetchRequest:req error:nil];
        obj = [results firstObject];
    }
    
    if(!obj) {
        if(alreadyExists)
            *alreadyExists = NO;
        
        obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                            inManagedObjectContext:self];
    } else {
        if(alreadyExists)
            *alreadyExists = YES;
    }
    
    return obj;
}

+ (NSMutableDictionary *)stkEditableMap
{
    static NSMutableDictionary *d = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        d = [[NSMutableDictionary alloc] init];
    });
    
    return d;
}

- (id)obtainEditableInstanceOfEntity:(NSString *)entityName
{
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
    [ctx setParentContext:self];
    
    NSManagedObject *o = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:entityName
                                                                             inManagedObjectContext:ctx]
                                  insertIntoManagedObjectContext:ctx];
    [[NSManagedObjectContext stkEditableMap] setObject:ctx forKey:[NSValue valueWithNonretainedObject:o]];
    
    return o;
}

- (id)obtainEditableCopy:(NSManagedObject *)object
{
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
    [ctx setParentContext:self];
    
    NSManagedObject *copy = [ctx existingObjectWithID:[object objectID] error:nil];
    
    [[NSManagedObjectContext stkEditableMap] setObject:ctx forKey:[NSValue valueWithNonretainedObject:copy]];
    
    return copy;
}

- (void)confirmChangesToEditableObject:(NSManagedObject *)object
{
    NSValue *v = [NSValue valueWithNonretainedObject:object];
    NSManagedObjectContext *ctx = [[NSManagedObjectContext stkEditableMap] objectForKey:v];
    [ctx save:nil];
    [[NSManagedObjectContext stkEditableMap] removeObjectForKey:v];
}

- (void)discardChangesToEditableObject:(NSManagedObject *)object
{
    NSValue *v = [NSValue valueWithNonretainedObject:object];
    [[NSManagedObjectContext stkEditableMap] removeObjectForKey:v];
}

@end
