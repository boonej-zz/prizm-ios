//
//  STKUser.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"
#import "STKProfileInformation.h"

@class STKActivityItem, STKPost, STKRequestItem;

@interface STKUser : NSManagedObject <STKJSONObject>

@property (nonatomic) NSString *userID;

@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *zipCode;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *profileID;


@property (nonatomic, strong) NSString *externalServiceType;
@property (nonatomic, strong) NSString *accountStoreID;

@property (nonatomic, retain) NSOrderedSet *requestItems;
@property (nonatomic, retain) NSOrderedSet *activityItems;
@property (nonatomic, retain) NSOrderedSet *posts;

@end

@interface STKUser (CoreDataGeneratedAccessors)

- (void)insertObject:(STKRequestItem *)value inRequestItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRequestItemsAtIndex:(NSUInteger)idx;
- (void)insertRequestItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRequestItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRequestItemsAtIndex:(NSUInteger)idx withObject:(STKRequestItem *)value;
- (void)replaceRequestItemsAtIndexes:(NSIndexSet *)indexes withRequestItems:(NSArray *)values;
- (void)addRequestItemsObject:(STKRequestItem *)value;
- (void)removeRequestItemsObject:(STKRequestItem *)value;
- (void)addRequestItems:(NSOrderedSet *)values;
- (void)removeRequestItems:(NSOrderedSet *)values;
- (void)insertObject:(STKActivityItem *)value inActivityItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromActivityItemsAtIndex:(NSUInteger)idx;
- (void)insertActivityItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeActivityItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInActivityItemsAtIndex:(NSUInteger)idx withObject:(STKActivityItem *)value;
- (void)replaceActivityItemsAtIndexes:(NSIndexSet *)indexes withActivityItems:(NSArray *)values;
- (void)addActivityItemsObject:(STKActivityItem *)value;
- (void)removeActivityItemsObject:(STKActivityItem *)value;
- (void)addActivityItems:(NSOrderedSet *)values;
- (void)removeActivityItems:(NSOrderedSet *)values;
- (void)insertObject:(STKPost *)value inPostsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPostsAtIndex:(NSUInteger)idx;
- (void)insertPosts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePostsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPostsAtIndex:(NSUInteger)idx withObject:(STKPost *)value;
- (void)replacePostsAtIndexes:(NSIndexSet *)indexes withPosts:(NSArray *)values;
- (void)addPostsObject:(STKPost *)value;
- (void)removePostsObject:(STKPost *)value;
- (void)addPosts:(NSOrderedSet *)values;
- (void)removePosts:(NSOrderedSet *)values;
@end
