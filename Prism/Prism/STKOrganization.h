//
//  STKOrganization.h
//  Prizm
//
//  Created by Jonathan Boone on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKTheme, STKUser, STKMute;

@interface STKOrganization : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * modifyDate;
@property (nonatomic, retain) NSString * welcomeMessage;
@property (nonatomic, retain) NSString * welcomeImageURL;
@property (nonatomic, retain) STKTheme *theme;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSString *logoURL;
@property (nonatomic, retain) STKUser *owner;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *mutes;
@property (nonatomic, retain) NSSet *groups;
@end

@interface STKOrganization (CoreDataGeneratedAccessors)

- (void)addMembersObject:(STKUser *)value;
- (void)removeMembersObject:(STKUser *)value;

- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

- (void)addMuteObject:(STKMute *)mute;
- (void)removeMuteObject:(STKMute *)mute;
- (void)addMutes:(NSSet *)values;
- (void)removeMutes:(NSSet *)values;

@end
