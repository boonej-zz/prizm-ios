//
//  STKContentStore.h
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPost.h"

extern NSString * const STKContentStoreErrorDomain;
typedef enum {
    STKContentStoreErrorCodeMissingArguments, // @[arg0, ...]
} STKContentStoreErrorCode;

@interface STKContentStore : NSObject

+ (STKContentStore *)store;

- (void)fetchRecommendedHashtags:(NSString *)baseString
                      completion:(void (^)(NSArray *suggestions))block;

- (void)fetchPostsForUser:(STKUser *)u
               completion:(void (^)(NSArray *posts, NSError *err, BOOL moreComing))block;

- (void)addPostWithCaption:(NSString *)caption
            imageURLString:(NSString *)imageURLString
                      type:(STKPostType)type
                completion:(void (^)(STKPost *post, NSError *err))block;

@end
