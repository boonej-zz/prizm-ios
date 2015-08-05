//
//  STKAnswer.h
//  Prizm
//
//  Created by Jonathan Boone on 8/4/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKQuestion, STKUser;

@interface STKAnswer : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) STKUser *user;
@property (nonatomic, retain) STKQuestion *question;

@end
