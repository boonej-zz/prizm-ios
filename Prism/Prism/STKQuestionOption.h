//
//  STKQuestionOption.h
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKQuestion;

@interface STKQuestionOption : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) STKQuestion *question;

@end
