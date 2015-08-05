//
//  STKQuestion.h
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;
@class STKSurvey;

@interface STKQuestion : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * scale;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * modifyDate;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) NSSet *options;
@property (nonatomic, retain) STKSurvey *survey;
@property (nonatomic, retain) NSString *type;
@end

@interface STKQuestion (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(NSManagedObject *)value;
- (void)removeAnswersObject:(NSManagedObject *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

- (void)addOptionsObject:(NSManagedObject *)value;
- (void)removeOptionsObject:(NSManagedObject *)value;
- (void)addOptions:(NSSet *)values;
- (void)removeOptions:(NSSet *)values;

@end
