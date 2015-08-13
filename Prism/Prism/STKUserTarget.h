//
//  STKUserTarget.h
//  Prizm
//
//  Created by Jonathan Boone on 8/13/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKSurvey, STKUser;

@interface STKUserTarget : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) STKUser *user;
@property (nonatomic, retain) STKSurvey *survey;

@end
