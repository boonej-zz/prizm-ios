//
//  STKContentStore.m
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKContentStore.h"
#import "STKBaseStore.h"
#import "STKPost.h"
#import "STKUserStore.h"
#import "STKUser.h"

@implementation STKContentStore
+ (STKContentStore *)store
{
    static STKContentStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKContentStore alloc] init];
    });
    return store;
}

- (NSManagedObjectContext *)context
{
    return [[STKBaseStore store] context];
}

- (NSURLSession *)session
{
    return [[STKBaseStore store] session];
}

- (void)fetchRecommendedHashtags:(NSString *)baseString
                      completion:(void (^)(NSArray *suggestions))block
{
    NSArray *basics = @[@"football", @"prism", @"family",
                        @"school", @"education", @"altruism",
                        @"wisconsin", @"volunteer", @"pride"];
    
    NSArray *matches = [basics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self beginswith %@", baseString]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block(matches);
    }];
}

- (void)addPostWithCaption:(NSString *)caption
            imageURLString:(NSString *)imageURLString
                      type:(STKPostType)type
                completion:(void (^)(STKPost *post, NSError *err))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block(nil, nil);
    }];
}

@end
