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
#import "STKActivityItem.h"
#import "STKRequestItem.h"
#import "STKConnection.h"
#import "STKFoursquareConnection.h"
#import "STKFoursquareLocation.h"
#import "STKPostComment.h"
#import "STKPostComment.h"
NSString * const STKContentStoreErrorDomain = @"STKContentStoreErrorDomain";

NSString * const STKContentFoursquareClientID = @"NPXBWJD343KPWSECQJM1NKJEZ4SYQ4RGRYWEBTLCU21PNUXO";
NSString * const STKContentFoursquareClientSecret = @"B2KSDXAPXQTWWMZLB2ODCCR3JOJVRQKCS1MNODYKD4TF2VCS";

NSString * const STKContentEndpointPost = @"/posts";


@interface STKContentStore ()

@property (nonatomic) BOOL hasBuiltTemporaryData;
@end

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


- (NSURLSession *)session
{
    return [[STKBaseStore store] session];
}

- (NSError *)errorForCode:(STKContentStoreErrorCode)code data:(id)data
{
    if(code == STKContentStoreErrorCodeMissingArguments) {
        return [NSError errorWithDomain:STKUserStoreErrorDomain code:code userInfo:@{@"missing arguments" : data}];
    }
    
    return [NSError errorWithDomain:STKUserStoreErrorDomain code:code userInfo:nil];
}

- (void)fetchLocationNamesForCoordinate:(CLLocationCoordinate2D)coord
                             completion:(void (^)(NSArray *locations, NSError *err))block
{
    STKFoursquareConnection *c = [[STKFoursquareConnection alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com"]
                                                                         endpoint:@"/v2/venues/search"];
    [c addQueryValue:[NSString stringWithFormat:@"%.2f,%.2f", coord.latitude, coord.longitude] forKey:@"ll"];
    [c addQueryValue:STKContentFoursquareClientID forKey:@"client_id"];
    [c addQueryValue:STKContentFoursquareClientSecret forKey:@"client_secret"];
    [c addQueryValue:@"20140101" forKey:@"v"];
    
    [c setModelGraph:@{@"venues" : @[@"STKFoursquareLocation"]}];
    [c getWithSession:[self session] completionBlock:^(id obj, NSError *err) {
        if(!err) {
            NSArray *venues = [obj objectForKey:@"venues"];
            block(venues, nil);
        } else {
            block(nil, err);
        }
    }];
}

- (void)fetchFeedForUser:(STKUser *)u
             inDirection:(STKContentStoreFetchDirection)fetchDirection
           referencePost:(STKPost *)referencePost
              completion:(void (^)(NSArray *posts, NSError *err))block;
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
                
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/users"];
        [c setIdentifiers:@[[u userID], @"feed"]];
        [c addQueryValue:@"30" forKey:@"limit"];
        if(referencePost) {
            [c addQueryValue:[referencePost referenceTimestamp] forKey:@"feature_identifier"];
            if(fetchDirection == STKContentStoreFetchDirectionOlder) {
                [c addQueryValue:[referencePost referenceTimestamp] forKey:@"older"];
            }
        } else {
            // Without a reference post, we don't have any posts so we just need to grab off the top of the stack
            [c addQueryValue:@"2000-01-01T00:00:00.000Z" forKey:@"feature_identifier"];
        }
        
        [c setModelGraph:@[@"STKPost"]];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *posts, NSError *err) {
            if(!err) {
                block(posts, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (void)fetchExplorePostsInDirection:(STKContentStoreFetchDirection)fetchDirection
                       referencePost:(STKPost *)referencePost
                              filter:(NSDictionary *)filterDict
                          completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/explore"];
        [c addQueryValue:@"30" forKey:@"limit"];
        
        if(referencePost) {
            [c addQueryValue:[referencePost referenceTimestamp] forKey:@"feature_identifier"];
            if(fetchDirection == STKContentStoreFetchDirectionOlder) {
                [c addQueryValue:[referencePost referenceTimestamp] forKey:@"older"];
            }
        } else {
            // Without a reference post, we don't have any posts so we just need to grab off the top of the stack
            [c addQueryValue:@"2000-01-01T00:00:00.000Z" forKey:@"feature_identifier"];
        }
        
        for(NSString *key in filterDict) {
            [c addQueryValue:[filterDict objectForKey:key] forKey:key];
        }
        
        [c setModelGraph:@[@"STKPost"]];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *obj, NSError *err) {
            if(!err) {
                block(obj, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (void)fetchPostsForLocationName:(NSString *)locationName
                        direction:(STKContentStoreFetchDirection)fetchDirection
                    referencePost:(STKPost *)referencePost
                       completion:(void (^)(NSArray *posts, NSError *err))block
{
    [self fetchExplorePostsInDirection:fetchDirection
                         referencePost:referencePost
                                filter:@{@"location_name" : locationName}
                            completion:block];
}

- (void)fetchExplorePostsInDirection:(STKContentStoreFetchDirection)fetchDirection
                       referencePost:(STKPost *)referencePost
                          completion:(void (^)(NSArray *posts, NSError *err))block
{
    [self fetchExplorePostsInDirection:fetchDirection referencePost:referencePost filter:nil completion:block];
}

- (void)searchPostsForHashtag:(NSString *)hashTag
                   completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/explore"];
        [c addQueryValue:@"30" forKey:@"limit"];
        [c addQueryValue:hashTag forKey:@"hash_tags"];
        
        
        [c setModelGraph:@[@"STKPost"]];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *obj, NSError *err) {
            if(!err) {
                block(obj, nil);
            } else {
                block(nil, err);
            }
        }];
    }];

}

- (void)fetchProfilePostsForUser:(STKUser *)user
                     inDirection:(STKContentStoreFetchDirection)fetchDirection
                   referencePost:(STKPost *)referencePost
                      completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/users"];
        [c setIdentifiers:@[[user userID], @"posts"]];
        [c addQueryValue:@"30" forKey:@"limit"];

        if(referencePost) {
            [c addQueryValue:[referencePost referenceTimestamp] forKey:@"feature_identifier"];
            if(fetchDirection == STKContentStoreFetchDirectionOlder) {
                [c addQueryValue:[referencePost referenceTimestamp] forKey:@"older"];
            }
        } else {
            // Without a reference post, we don't have any posts so we just need to grab off the top of the stack
            [c addQueryValue:@"2000-01-01T00:00:00.000Z" forKey:@"feature_identifier"];
        }
        
        
        [c setModelGraph:@[@"STKPost"]];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *obj, NSError *err) {
            if(!err) {
                obj = [obj sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted"
                                                                                       ascending:NO]]];
                block(obj, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (void)likePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block
{
    [post setLikeCount:[post likeCount] + 1];
    [post setPostLikedByCurrentUser:YES];

    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            [post setPostLikedByCurrentUser:NO];
            [post setLikeCount:[post likeCount] - 1];

            block(nil, err);
            return;
        }
        
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
        [c setIdentifiers:@[[post postID], @"like"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID]
                  forKey:@"creator"];

        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [post setPostLikedByCurrentUser:NO];
                [post setLikeCount:[post likeCount] - 1];
            }
            block(post, err);
        }];
    }];
}

- (void)flagPost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err){
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
        [c setIdentifiers:@[[post postID], @"flag"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"reporter"];
        
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err || ![obj isKindOfClass:[NSString class]]){
                block(nil, err);
                return;
            }
            block(post, err);
        }];
         
    }];
}

- (void)unlikePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block
{
    [post setLikeCount:[post likeCount] - 1];
    [post setPostLikedByCurrentUser:NO];

    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            [post setLikeCount:[post likeCount] + 1];
            [post setPostLikedByCurrentUser:YES];

            block(nil, err);
            return;
        }
        
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
        [c setIdentifiers:@[[post postID], @"unlike"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID]
                  forKey:@"creator"];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [post setLikeCount:[post likeCount] + 1];
                [post setPostLikedByCurrentUser:YES];
            }
            block(post, err);
        }];
    }];
}

- (void)deletePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block
{
    [post setStatus:STKPostStatusDeleted];
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            [post setStatus:nil];
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/posts"];
        [c setIdentifiers:@[[post postID]]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"creator"];
        
        [c deleteWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [post setStatus:nil];
            }
            
            block(obj, err);
        }];
    }];
}

- (void)likeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block
{
    if(![comment commentID]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, nil);
        }];
        return;
    }
    
    [comment setLikeCount:[comment likeCount] + 1];
    [comment setLikedByCurrentUser:YES];
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            [comment setLikeCount:[comment likeCount] - 1];
            [comment setLikedByCurrentUser:NO];
            
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
        [c setIdentifiers:@[[[comment post] postID], @"comments", [comment commentID], @"like"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"creator"];
        [c postWithSession:[self session] completionBlock:^(STKPostComment *obj, NSError *err) {
            if(err) {
                [comment setLikeCount:[comment likeCount] - 1];
                [comment setLikedByCurrentUser:NO];
            }
            block(obj, err);
        }];
    }];
}

- (void)unlikeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block
{
    if(![comment commentID]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, nil);
        }];
        return;
    }

    [comment setLikeCount:[comment likeCount] - 1];
    [comment setLikedByCurrentUser:NO];
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            [comment setLikeCount:[comment likeCount] + 1];
            [comment setLikedByCurrentUser:YES];
            
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
        [c setIdentifiers:@[[[comment post] postID], @"comments", [comment commentID], @"unlike"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"creator"];
        [c postWithSession:[self session] completionBlock:^(STKPostComment *obj, NSError *err) {
            if(err) {
                [comment setLikeCount:[comment likeCount] + 1];
                [comment setLikedByCurrentUser:YES];
            }
            block(obj, err);
        }];
    }];
}


- (void)addComment:(NSString *)comment toPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block
{
    NSArray *currentComments = [p comments];
    STKPostComment *pc = [[STKPostComment alloc] init];
    [pc setUser:[[STKUserStore store] currentUser]];
    [pc setText:comment];
    [pc setDate:[NSDate date]];
    
    [p setComments:[[p comments] arrayByAddingObject:pc]];
    [p setCommentCount:[p commentCount] + 1];
    
    void (^reversal)(void) = ^{
        [p setComments:currentComments];
        [p setCommentCount:[p commentCount] -1];
    };
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            reversal();
            
            block(nil, err);
            return;
        }
       
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
        [c setIdentifiers:@[[p postID], @"comments"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID]
                  forKey:@"creator"];
        [c addQueryValue:comment forKey:@"text"];

        [c postWithSession:[self session] completionBlock:^(NSDictionary *comments, NSError *err) {
            if(err) {
                reversal();
            } else {
                int count = [[comments objectForKey:@"comments_count"] intValue];
                [p setCommentCount:count];
                
                NSDictionary *newCommentDict = [comments objectForKey:@"comments"];
                STKPostComment *newComment = [[STKPostComment alloc] init];
                [newComment readFromJSONObject:newCommentDict];
                [p setComments:[currentComments arrayByAddingObjectsFromArray:@[newComment]]];
            }
            block(p, err);
        }];

    }];
}

- (void)deleteComment:(STKPostComment *)comment completion:(void (^)(STKPost *p, NSError *err))block
{
    NSArray *currentComments = [[comment post] comments];
    int currentCount = [[comment post] commentCount];
    void (^reversal)(void) = ^{
        [[comment post] setComments:currentComments];
        [[comment post] setCommentCount:currentCount];
    };
    
    NSArray *comments = [[[comment post] comments] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"commentID != %@", [comment commentID]]];
    [[comment post] setComments:comments];
    [[comment post] setCommentCount:[[comment post] commentCount] - 1];
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            reversal();
            
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
        [c setIdentifiers:@[[[comment post] postID], @"comments", [comment commentID]]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID]
                  forKey:@"creator"];
        
        [c deleteWithSession:[self session] completionBlock:^(id comments, NSError *err) {
            if(err) {
                reversal();
            }
            block([comment post], err);
        }];
        
    }];
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

- (void)addPostWithInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }

        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/users"];
        [c setIdentifiers:@[[[[STKUserStore store] currentUser] userID], @"posts"]];
        
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"creator"];
        
        for(NSString *key in info) {
            [c addQueryValue:[info objectForKey:key] forKey:key];
        }
        
        // This will wash away any Visibility modifiers as intended
        if([[info objectForKey:STKPostTypeKey] isEqualToString:STKPostTypePersonal]) {
            [c addQueryValue:STKPostVisibilityPrivate forKey:STKPostVisibilityKey];
        }
        
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(!err) {
                
            } else {
            
            }
            
            block(obj, err);
        }];
    }];
}

- (void)editPost:(STKPost *)p withInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/posts"];
        [c setIdentifiers:@[[p postID]]];
        
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"creator"];
        
        for(NSString *key in info) {
            [c addQueryValue:[info objectForKey:key] forKey:key];
        }
//        [c setModelGraph:@[p]];
        [c putWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(!err) {
                
            } else {
                
            }
            
            block(obj, err);
        }];
    }];
}

- (void)fetchCommentsForPost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/posts"];
        [c setIdentifiers:@[[post postID], @"comments"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"creator"];
        [c setModelGraph:@[@{@"comments": @[[STKPostComment class]]}]];
        [c getWithSession:[self session] completionBlock:^(NSDictionary *comments, NSError *err) {
            
            if(!err) {
                NSArray *allComments = [comments objectForKey:@"comments"];
                [post setComments:allComments];
            } else {
                
            }
            
            block(post, err);
        }];
    }];
}


@end
