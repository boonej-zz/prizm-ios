//
//  STKLeaderboardItem.h
//  Prizm
//
//  Created by Jonathan Boone on 8/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKOrganization, STKUser;

@interface STKLeaderboardItem : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) STKUser *user;
@property (nonatomic, retain) STKOrganization *organization;
@property (nonatomic, retain) NSNumber * surveys;

@end
