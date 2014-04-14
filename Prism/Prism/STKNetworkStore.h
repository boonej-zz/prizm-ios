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
@end
