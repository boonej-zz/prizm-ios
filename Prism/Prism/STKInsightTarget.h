//
//  STKInsightTarget.h
//  Prizm
//
//  Created by Jonathan Boone on 10/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKInsight, STKUser;

@interface STKInsightTarget : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSDate * sentDate;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * disliked;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) STKUser *target;
@property (nonatomic, retain) STKInsight *insight;

@end
