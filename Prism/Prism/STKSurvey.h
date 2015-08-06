//
//  STKSurvey.h
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKGroup, STKQuestion, STKUser, STKOrganization;

@interface STKSurvey : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * modifyDate;
@property (nonatomic, retain) NSNumber * numberOfQuestions;
@property (nonatomic, retain) NSNumber * targetAll;
@property (nonatomic, retain) STKUser *creator;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *questions;
@property (nonatomic, retain) NSSet *completed;
@property (nonatomic, retain) STKOrganization *organization;
@property (nonatomic, retain) NSNumber *points;
@property (nonatomic, retain) NSNumber *rank;
@property (nonatomic, retain) NSString *duration;

@end

@interface STKSurvey (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(STKGroup *)value;
- (void)removeGroupsObject:(STKGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addQuestionsObject:(STKQuestion *)value;
- (void)removeQuestionsObject:(STKQuestion *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;

- (void)addCompletedObject:(STKUser *)value;
- (void)removeCompletedObject:(STKUser *)value;
- (void)addCompleted:(NSSet *)values;
- (void)removeCompleted:(NSSet *)values;

@end
