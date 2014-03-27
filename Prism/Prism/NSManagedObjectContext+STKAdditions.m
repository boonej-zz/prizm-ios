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
                                                    object:(id)object
                                                  matchMap:(NSDictionary *)matchMap
                                             alreadyExists:(BOOL *)alreadyExists
{
    id obj = nil;
    if(matchMap) {
        NSMutableArray *predicates = [NSMutableArray array];
        for(NSString *key in matchMap) {
            NSPredicate *p = nil;
            if([object isKindOfClass:[NSString class]]) {
                p = [NSPredicate predicateWithFormat:@"%K == %@", key, object];
            } else {
                p = [NSPredicate predicateWithFormat:@"%K == %@", key, [object valueForKeyPath:[matchMap objectForKey:key]]];
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

@end
