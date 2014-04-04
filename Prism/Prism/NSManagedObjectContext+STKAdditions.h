//
//  NSManagedObjectContext+STKAdditions.h
//  Prism
//
//  Created by Joe Conway on 3/26/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@interface NSManagedObjectContext (STKAdditions)

- (NSManagedObject <STKJSONObject> *)instanceForEntityName:(NSString *)entityName
                                                    object:(id)object
                                                  matchMap:(NSDictionary *)matchMap
                                             alreadyExists:(BOOL *)alreadyExists;

// If you call one of these....
- (id)obtainEditableCopy:(NSManagedObject *)object;
- (id)obtainEditableInstanceOfEntity:(NSString *)entityName;

// You must call one of these in the future
- (void)confirmChangesToEditableObject:(NSManagedObject *)object;
- (void)discardChangesToEditableObject:(NSManagedObject *)object;

@end
