//
//  STKMessage.h
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKGroup, STKOrganization, STKUser, STKMessageMetaData;

@interface STKMessage : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) STKUser *creator;
@property (nonatomic, retain) STKGroup *group;
@property (nonatomic, retain) STKOrganization *organization;
@property (nonatomic, retain) STKMessageMetaData *metaData;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) NSString * uniqueID;
@end

@interface STKMessage (CoreDataGeneratedAccessors)

- (void)addLikesObject:(STKUser *)value;
- (void)removeLikesObject:(STKUser *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

@end
