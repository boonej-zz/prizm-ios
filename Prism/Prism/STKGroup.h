//
//  STKGroup.h
//  Prizm
//
//  Created by Jonathan Boone on 4/14/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class NSManagedObject, STKOrganization, STKUser;

@interface STKGroup : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * groupDescription;
@property (nonatomic, retain) STKOrganization *organization;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) STKUser *leader;

@end

@interface STKGroup (CoreDataGeneratedAccessors)

- (void)addMembersObject:(NSManagedObject *)value;
- (void)removeMembersObject:(NSManagedObject *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
