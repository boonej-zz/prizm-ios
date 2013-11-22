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

@end
