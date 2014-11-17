//
//  STKInsight.h
//  Prizm
//
//  Created by Jonathan Boone on 10/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

@class STKHashTag, STKUser;

@interface STKInsight : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) NSNumber * dislikesCount;
@property (nonatomic, retain) NSNumber * tagsCount;
@property (nonatomic, retain) NSNumber * hashTagsCount;
@property (nonatomic, retain) STKUser *creator;
@property (nonatomic, retain) NSSet *hashTags;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *linkTitle;
@end

@interface STKInsight (CoreDataGeneratedAccessors)

- (void)addHashTagsObject:(STKHashTag *)value;
- (void)removeHashTagsObject:(STKHashTag *)value;
- (void)addHashTags:(NSSet *)values;
- (void)removeHashTags:(NSSet *)values;

- (void)addTagsObject:(STKUser *)value;
- (void)removeTagsObject:(STKUser *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (NSURL *)linkURL;

@end
