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

@class NSManagedObject, STKOrganization, STKUser, STKMute;

@interface STKGroup : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * groupDescription;
@property (nonatomic, retain) STKOrganization *organization;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) STKUser *leader;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSSet *mutes;
@property (nonatomic, retain) NSNumber *unreadCount;

@end

@interface STKGroup (CoreDataGeneratedAccessors)

- (void)addMembersObject:(NSManagedObject *)value;
- (void)removeMembersObject:(NSManagedObject *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

- (void)addMuteObject:(STKMute *)mute;
- (void)removeMuteObject:(STKMute *)mute;
- (void)addMutes:(NSSet *)values;
- (void)removeMutes:(NSSet *)values;

@end
