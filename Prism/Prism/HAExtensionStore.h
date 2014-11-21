//
//  HAExtensionStore.h
//  Prizm
//
//  Created by Eric Kenny on 11/16/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKNetworkStore.h"

@interface HAExtensionStore : STKNetworkStore

- (void)createPostsFromExtensionDictionary:(NSDictionary *)post;

@end
