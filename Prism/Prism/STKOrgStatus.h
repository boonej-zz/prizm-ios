//
//  STKOrgStatus.h
//  Prizm
//
//  Created by Jonathan Boone on 4/14/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKGroup, STKOrganization, STKUser;

@interface STKOrgStatus : NSManagedObject<STKJSONObject>
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) STKOrganization *organization;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) STKUser *member;
@end

@interface STKOrgStatus (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(STKGroup *)value;
- (void)removeGroupsObject:(STKGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
