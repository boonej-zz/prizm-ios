//
//  STKProfile.h
//  Prism
//
//  Created by Joe Conway on 1/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKUser;



@interface STKProfile : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * profileID;
@property (nonatomic, retain) NSString * profilePhotoPath;
@property (nonatomic, retain) NSString * coverPhotoPath;
@property (nonatomic, retain) NSString * profileType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, strong) NSString *accoladeCount;
@property (nonatomic, strong) NSString *followingCount;
@property (nonatomic, strong) NSString *followedCount;
@property (nonatomic, strong) NSString *trustCount;
@property (nonatomic, strong) NSString *postCount;

@property (nonatomic, strong) NSString *entityID;

@property (nonatomic, retain) STKUser *user;


@end
