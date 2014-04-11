//
//  STKNetworkStore.h
//  Prism
//
//  Created by Joe Conway on 4/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKUser;

@import Social;

@interface STKNetworkStore : NSObject

+ (STKNetworkStore *)store;

- (void)checkAndFetchPostsFromOtherNetworksForUser:(STKUser *)user
                                        completion:(void (^)(STKUser *updatedUser, NSError *err))block;

- (void)transferPostsFromInstagramWithToken:(NSString *)token
                              lastMinimumID:(NSString *)minID
                                 completion:(void (^)(NSString *lastID, NSError *err))block;

- (void)transferPostsFromTwitterAccount:(ACAccount *)account
                             completion:(void (^)(NSString *lastID, NSError *err))block;
@end
