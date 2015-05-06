//
//  STKMute.h
//  Prizm
//
//  Created by Jonathan Boone on 5/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKGroup, STKOrganization, STKUser;

@interface STKMute : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * revokeDate;
@property (nonatomic, retain) STKUser *user;
@property (nonatomic, retain) STKOrganization *organization;
@property (nonatomic, retain) STKGroup *group;

@end
