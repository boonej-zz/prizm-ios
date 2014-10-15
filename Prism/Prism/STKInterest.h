//
//  STKInterest.h
//  Prizm
//
//  Created by Jonathan Boone on 10/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKInterest;

@interface STKInterest : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSNumber * topLevel;
@property (nonatomic, retain) NSSet *subinterests;
@property (nonatomic, retain) STKInterest *parent;
@end

@interface STKInterest (CoreDataGeneratedAccessors)

- (void)addSubinterestsObject:(STKInterest *)value;
- (void)removeSubinterestsObject:(STKInterest *)value;
- (void)addSubinterests:(NSSet *)values;
- (void)removeSubinterests:(NSSet *)values;

@end
