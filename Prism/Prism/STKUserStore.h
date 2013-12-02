//
//  STKUserStore.h
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKUser, STKPost, STKActivityItem, STKRequestItem;

@interface STKUserStore : NSObject

+ (STKUserStore *)store;

@property (nonatomic, strong) STKUser *currentUser;

- (void)fetchFeedForCurrentUser:(void (^)(NSArray *posts, NSError *error, BOOL moreComing))block;
- (void)fetchActivityForCurrentUser:(void (^)(NSArray *activity, NSError *error, BOOL moreComing))block;

- (void)fetchAccountsForDevice:(void (^)(NSArray *accounts, NSError *err))block;

- (void)fetchRecommendedHashtags:(NSString *)hashtag completion:(void (^)(NSArray *hashtags, NSError *error))block;
@end
