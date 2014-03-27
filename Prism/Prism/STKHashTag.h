//
//  STKHashTag.h
//  Prism
//
//  Created by Joe Conway on 3/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKPost;

@interface STKHashTag : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSSet *posts;

@end

@interface STKHashTag (CoreDataGeneratedAccessors)

- (void)addPostsObject:(STKPost *)value;
- (void)removePostsObject:(STKPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
