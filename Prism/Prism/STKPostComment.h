//
//  STKPostComment.h
//  Prism
//
//  Created by Joe Conway on 2/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"
@class STKUser, STKPost, STKHashTag;

@interface STKPostComment : NSManagedObject <STKJSONObject>

@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) int likeCount;

@property (nonatomic, strong) STKUser *creator;
@property (nonatomic, strong) NSSet *likes;
@property (nonatomic, strong) STKPost *post;

@property (nonatomic, strong) NSSet *activities;

@property (nonatomic, retain) NSSet *hashTags;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic) int hashTagsCount;
@property (nonatomic) int tagsCount;


- (BOOL)isLikedByUser:(STKUser *)u;

- (NSDictionary *)mixpanelProperties;

@end


@interface STKPostComment (CoreDataGeneratedAccessors)

- (void)addHashTagsObject:(STKHashTag *)value;
- (void)removeHashTagsObject:(STKHashTag *)value;
- (void)addHashTags:(NSSet *)values;
- (void)removeHashTags:(NSSet *)values;

- (void)addTagsObject:(STKUser *)value;
- (void)removeTagsObject:(STKUser *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end