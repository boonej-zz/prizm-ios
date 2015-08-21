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
#import "STKConnection.h"
#import "STKFoursquareConnection.h"
#import "STKFoursquareLocation.h"
#import "STKPostComment.h"
#import "STKFetchDescription.h"
#import "Mixpanel.h"
#import "STKHashTag.h"
#import "STKUser.h"
#import "STKInsightTarget.h"
#import "STKInsight.h"

NSString * const STKContentStoreErrorDomain = @"STKContentStoreErrorDomain";

NSString * const STKContentFoursquareClientID = @"FGEGQPWV4ONDR1O30NCGZYALDVHJMBHIXZOLUNB0E0GVNE24";
NSString * const STKContentFoursquareClientSecret = @"4XPKWKBIGSVZD3YQESZEHTSVZ45FFTNCGQV3OLLEBJR1ETVI";

NSString * const STKContentEndpointPost = @"/posts";


NSString * const STKContentStorePostDeletedNotification = @"STKContentStorePostDeletedNotification";
NSString * const STKContentStorePostDeletedKey = @"STKContentStorePostDeletedKey";

@interface STKContentStore ()

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
                                                                      identifiers:@[@"/v2", @"venues", @"search"]];

    [c addQueryValue:[NSString stringWithFormat:@"%.20f,%.20f", coord.latitude, coord.longitude] forKey:@"ll"];
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

- (void)fetchPostWithUniqueId:(NSString *)uniqueId completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/posts", uniqueId]];
        
//        STKQueryObject *q = [[STKQueryObject alloc] init];
//        STKSearchQuery *sq = [STKSearchQuery searchQueryForField:@"_id" value:uniqueId];
//        STKContainQuery *cq = [STKContainQuery containQueryForField:@"followers" key:@"_id" value:[[self currentUser] uniqueID]];
//        [q addSubquery:cq];
//        [q addSubquery:sq];
//        [c setQueryObject:q];
        
        [c setModelGraph:@[@"STKPost"]];
        [c setContext:[[STKUserStore store] context]];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(STKPost *post, NSError *err) {
            if(!err) {
                block(post, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (NSArray *)cachedPostsForPredicate:(NSPredicate *)predicate
                    fetchDescription:(STKFetchDescription *)desc
{
    NSMutableArray *preds = [NSMutableArray array];
    for(NSString *key in [desc filterDictionary]) {
        NSString *value = [[desc filterDictionary] objectForKey:key];
        if([value isEqualToString:STKQueryObjectFilterExists]) {
            [preds addObject:[NSPredicate predicateWithFormat:@"%K != nil", key]];
        } else {
            [preds addObject:[NSPredicate predicateWithFormat:@"%K == %@", key, [[desc filterDictionary] objectForKey:key]]];
        }
    }
    
    if([preds count] > 0) {
        [preds addObject:predicate];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:preds];
    }
    
    STKPost *referencePost = [desc referenceObject];
    if(!referencePost) {
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"STKPost"];
        [req setPredicate:predicate];
        [req setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
        [req setFetchLimit:[desc limit]];

        NSArray *results = [[[STKUserStore store] context] executeFetchRequest:req error:nil];
        return results;
    } else {
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"STKPost"];
        [req setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
        [req setFetchLimit:[desc limit]];
        
        if([desc direction] == STKQueryObjectPageNewer) {
            [req setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate,
                                                                                   [NSPredicate predicateWithFormat:@"datePosted > %@", [referencePost datePosted]]]]];
        } else if([desc direction] == STKQueryObjectPageOlder) {
            [req setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate,
                                                                                   [NSPredicate predicateWithFormat:@"datePosted < %@", [referencePost datePosted]]]]];
        }
        
        return [[[STKUserStore store] context] executeFetchRequest:req error:nil];
    }
    return @[];
}

- (void)fetchFeedForUser:(STKUser *)u
        fetchDescription:(STKFetchDescription *)desc
              completion:(void (^)(NSArray *posts, NSError *err))block
{
    int fetchLimit = [desc limit];
    STKPost *referencePost = [desc referenceObject];
    STKQueryObjectPage direction = [desc direction];

    if (fetchLimit == 0) {
        fetchLimit = 30;
        [desc setLimit:30];
    }

    
    NSArray *cached = [self cachedPostsForPredicate:[NSPredicate predicateWithFormat:@"fInverseFeed == %@", [[STKUserStore store] currentUser]]
                                   fetchDescription:desc];

    if([cached count] > 0) {
        if(direction == STKQueryObjectPageNewer) {
            referencePost = [cached firstObject];
        } else if (direction == STKQueryObjectPageOlder) {
            referencePost = [cached lastObject];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(cached, nil);
        }];
    }
    if (u) {
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        

        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/users", [u uniqueID], @"feed"]];
        
        STKQueryObject *q = [[STKQueryObject alloc] init];
        [q setLimit:fetchLimit];
        [q setPageDirection:direction];
        [q setPageKey:STKPostDateCreatedKey];
        [q setPageValue:[STKTimestampFormatter stringFromDate:[referencePost datePosted]]];
        
        STKResolutionQuery *rq = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [q addSubquery:rq];
        
        STKResolutionQuery *tagQ = [STKResolutionQuery resolutionQueryForField:@"tags"];
        [q addSubquery:tagQ];
        
        STKContainQuery *cq = [STKContainQuery containQueryForField:@"likes" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]];
        [q addSubquery:cq];
        
        STKResolutionQuery *originPost = [STKResolutionQuery resolutionQueryForField:@"origin_post_id"];
        
        STKResolutionQuery *originPostCreator = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [originPost addSubquery:originPostCreator];
        [q addSubquery:originPost];
        
        [c setQueryObject:q];
        
        [c setResolutionMap:@{@"User" : @"STKUser", @"Post" : @"STKPost"}];
        [c setModelGraph:@[@"STKPost"]];
        [c setContext:[[STKUserStore store] context]];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *posts, NSError *err) {
            if(!err) {
//                [[[[STKUserStore store] currentUser] mutableSetValueForKeyPath:@"fFeedPosts"] addObjectsFromArray:posts];
//                [[[STKUserStore store] currentUser] addFFeedPosts:[NSSet setWithArray:posts]];
                for(STKPost *p in posts) {
                    [p setFInverseFeed:[[STKUserStore store] currentUser]];
                }
                [[[STKUserStore store] context] save:nil];
                block(posts, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
    } else {
        block(nil, nil);
    }
}

- (void)fetchExplorePostsWithFetchDescription:(STKFetchDescription *)desc
                                   completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/explore"]];
        STKQueryObject *q = [[STKQueryObject alloc] init];
        [q setLimit:60];
        if([desc referenceObject]) {
            [q setPageDirection:[desc direction]];
            [q setPageKey:STKPostDateCreatedKey];
            [q setPageValue:[STKTimestampFormatter stringFromDate:[(STKPost *)[desc referenceObject] datePosted]]];
        }
        NSMutableDictionary *filters = [NSMutableDictionary dictionary];
        [filters setObject:@"infinite" forKey:@"feed"];
        [filters addEntriesFromDictionary:[self serverFilterMapFromLocalFilterMap:[desc filterDictionary]]];
        [q setFilters:filters];
        
        if([[desc sortDescriptors] count] > 0) {
            NSSortDescriptor *sd = [[desc sortDescriptors] firstObject];
            [q setSortKey:[STKPost remoteKeyForLocalKey:[sd key]]];
            if([sd ascending]) {
                [q setSortOrder:STKQueryObjectSortAscending];
            } else {
                [q setSortOrder:STKQueryObjectSortDescending];
            }
        }
        
        STKResolutionQuery *rq = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [q addSubquery:rq];
        
        STKResolutionQuery *tagQ = [STKResolutionQuery resolutionQueryForField:@"tags"];
        [q addSubquery:tagQ];

        STKContainQuery *cq = [STKContainQuery containQueryForField:@"likes" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]];
        [q addSubquery:cq];
        
        STKResolutionQuery * originPost = [STKResolutionQuery resolutionQueryForField:@"origin_post_id"];
        STKResolutionQuery * originPostCreator = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [originPost addSubquery:originPostCreator];
        [q addSubquery:originPost];
        
        [c setQueryObject:q];
        
        [c setResolutionMap:@{@"User" : @"STKUser", @"Post" : @"STKPost"}];
        [c setModelGraph:@[@"STKPost"]];
        [c setContext:[[STKUserStore store] context]];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *obj, NSError *err) {
            if(!err) {
                [[[STKUserStore store] context] save:nil];
                block(obj, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}


- (void)searchPostsForHashtag:(NSString *)hashTag
                   completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/search", @"hashtags", hashTag]];
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

- (void)fetchLikedPostsForUser:(STKUser *)user fetchDescription:(STKFetchDescription *)desc completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/users", [user uniqueID], @"likes"]];
        [c setShouldReturnArray:YES];
        STKQueryObject *q = [[STKQueryObject alloc] init];
        [q setPageDirection:[desc direction]];
        [q setPageKey:STKPostDateCreatedKey];
        [q setPageValue:[STKTimestampFormatter stringFromDate:[[desc referenceObject] datePosted]]];
        
        [q setFilters:[self serverFilterMapFromLocalFilterMap:[desc filterDictionary]]];
        
        STKResolutionQuery *tagQ = [STKResolutionQuery resolutionQueryForField:@"tags"];
        [q addSubquery:tagQ];
        
        STKResolutionQuery *rq = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [q addSubquery:rq];
        
        STKContainQuery *cq = [STKContainQuery containQueryForField:@"likes" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]];
        [q addSubquery:cq];
        
        [c setQueryObject:q];
        [c setResolutionMap:@{@"User" : @"STKUser"}];
        [c setModelGraph:@[@"STKPost"]];
        [c setContext:[[STKUserStore store] context]];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        [c getWithSession:[self session] completionBlock:^(NSArray *obj, NSError *err) {
            if(!err) {
                obj = [obj sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted"
                                                                                       ascending:NO]]];
                for(STKPost *p in obj) {
                    [p setFInverseProfile:user];
                }
                
                [[[STKUserStore store] context] save:nil];
                block(obj, nil);
            } else {
                block(nil, err);
            }
        }];
        
    }];
}

- (NSDictionary *)serverFilterMapFromLocalFilterMap:(NSDictionary *)filterMap
{
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    for(NSString *key in filterMap) {
        
        if([key isEqualToString:@"tags.uniqueID"]) {
            [filters setObject:[filterMap objectForKey:key] forKey:@"tags._id"];

        } else {
            NSString *remoteKey = [STKPost remoteKeyForLocalKey:key];
            [filters setObject:[filterMap objectForKey:key] forKey:remoteKey];
        }
    }

    if([filters count] == 0)
        return nil;
    
    return filters;
}

- (void)fetchProfilePostsForUser:(STKUser *)user
                fetchDescription:(STKFetchDescription *)desc
                      completion:(void (^)(NSArray *posts, NSError *err))block
{/*
    NSArray *cached = [self cachedPostsForPredicate:[NSPredicate predicateWithFormat:@"fInverseProfile == %@", user]
                                   fetchDescription:desc];
    
    STKPost *referencePost = [desc referenceObject];
    if([cached count] > 0) {
        if([desc direction] == STKQueryObjectPageNewer) {
            referencePost = [cached firstObject];
        } else if ([desc direction] == STKQueryObjectPageOlder) {
            referencePost = [cached lastObject];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(cached, nil);
        }];
    }*/
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/users", [user uniqueID], @"posts"]];
        
        STKQueryObject *q = [[STKQueryObject alloc] init];
        [q setLimit:30];
        [q setPageDirection:[desc direction]];
        [q setPageKey:STKPostDateCreatedKey];
        [q setPageValue:[STKTimestampFormatter stringFromDate:[[desc referenceObject] datePosted]]];
        
        [q setFilters:[self serverFilterMapFromLocalFilterMap:[desc filterDictionary]]];
        
        STKResolutionQuery *tagQ = [STKResolutionQuery resolutionQueryForField:@"tags"];
        [q addSubquery:tagQ];
        
        STKResolutionQuery *rq = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [q addSubquery:rq];
        
        STKContainQuery *cq = [STKContainQuery containQueryForField:@"likes" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]];
        [q addSubquery:cq];
        
        [c setQueryObject:q];
        
        [c setResolutionMap:@{@"User" : @"STKUser"}];
        [c setModelGraph:@[@"STKPost"]];
        [c setContext:[[STKUserStore store] context]];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        [c setShouldReturnArray:YES];
        [c getWithSession:[self session] completionBlock:^(NSArray *obj, NSError *err) {
            if(!err) {
                obj = [obj sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted"
                                                                                       ascending:NO]]];
                for(STKPost *p in obj) {
                    [p setFInverseProfile:user];
                }
                
                [[[STKUserStore store] context] save:nil];
                block(obj, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (void)fetchInsightsForUser:(STKUser *)user
            fetchDescription:(STKFetchDescription *)desc
                  completion:(void (^)(NSArray *insights, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/users", [user uniqueID], @"insights"]];
        
        STKQueryObject *query = [[STKQueryObject alloc] init];
        STKResolutionQuery *insightQuery = [STKResolutionQuery resolutionQueryForField:@"insight"];
        STKResolutionQuery *targetQuery = [STKResolutionQuery resolutionQueryForField:@"target"];
        STKResolutionQuery *creatorQuery = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [query addSubquery:insightQuery];
        [query addSubquery:targetQuery];
        [query addSubquery:creatorQuery];
        [c setQueryObject:query];
        [c setModelGraph:@[@"STKInsightTarget"]];
        [c setExistingMatchMap:@{@"uniqueID": @"_id"}];
        [c setResolutionMap:@{@"User": @"STKUser", @"Insight": @"STKInsight"}];
        [c setShouldReturnArray:YES];
        [c setContext:[[STKUserStore store] context]];
        [c getWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(!err) {
                [[[STKUserStore store] context] save:nil];
            }
            block(obj, err);
        }];
    }];
}

- (void)likeInsight:(STKInsightTarget *)insightTarget completion:(void (^)(NSError *))block
{
    [insightTarget setLiked:[NSNumber numberWithBool:YES]];
    [insightTarget setDisliked:[NSNumber numberWithBool:NO]];
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if (err){
            block(err);
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/insights", [insightTarget uniqueID], @"like"]];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            block(err);
        }];
    }];
}

- (void)dislikeInsight:(STKInsightTarget *)insightTarget completion:(void(^)(NSError *err))block
{
    [insightTarget setLiked:[NSNumber numberWithBool:NO]];
    [insightTarget setDisliked:[NSNumber numberWithBool:YES]];
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if (err){
            block(err);
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/insights", [insightTarget uniqueID], @"dislike"]];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            block(err);
        }];
    }];
}


- (void)likePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block
{
    [post setLikeCount:[post likeCount] + 1];
    [[post mutableSetValueForKey:@"likes"] addObject:[[STKUserStore store] currentUser]];

    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            [[post mutableSetValueForKey:@"likes"] removeObject:[[STKUserStore store] currentUser]];

            [post setLikeCount:[post likeCount] - 1];

            block(nil, err);
            return;
        }
        
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [post uniqueID], @"like"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID]
                  forKey:@"creator"];
        [c setModelGraph:@[post]];
        [c setContext:[[STKUserStore store] context]];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                [[post mutableSetValueForKey:@"likes"] removeObject:[[STKUserStore store] currentUser]];
                [post setLikeCount:[post likeCount] - 1];
            }
            [[[STKUserStore store] context] save:nil];
            block(post, err);
           
            [self trackLikePost:post];
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
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [post uniqueID], @"flag"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID] forKey:@"reporter"];
        
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
    [[post mutableSetValueForKey:@"likes"] removeObject:[[STKUserStore store] currentUser]];

    void (^reversal)(void) = ^{
        [post setLikeCount:[post likeCount] + 1];
        [[post mutableSetValueForKey:@"likes"] addObject:[[STKUserStore store] currentUser]];
        [[[STKUserStore store] context] save:nil];
    };
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            reversal();
            
            block(nil, err);
            return;
        }
        
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [post uniqueID], @"unlike"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID]
                  forKey:@"creator"];
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(err) {
                reversal();
            }
            [[[STKUserStore store] context] save:nil];
            block(post, err);
        }];
    }];
}

- (void)deletePost:(STKPost *)post completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/posts", [post uniqueID]]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID] forKey:@"creator"];
        
        [c deleteWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(!err) {
                [[NSNotificationCenter defaultCenter] postNotificationName:STKContentStorePostDeletedNotification
                                                                    object:self
                                                                  userInfo:@{STKContentStorePostDeletedKey : post}];
                [[[STKUserStore store] context] deleteObject:post];
                [[[STKUserStore store] context] save:nil];
            }
            
            block(obj, err);
        }];
    }];
}

- (void)likeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block
{
    if(![comment uniqueID]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, nil);
        }];
        return;
    }
    
    [comment setLikeCount:[comment likeCount] + 1];
    [[comment mutableSetValueForKey:@"likes"] addObject:[[STKUserStore store] currentUser]];
    
    void (^reversal)(void) = ^{
        [comment setLikeCount:[comment likeCount] - 1];
        [[comment mutableSetValueForKey:@"likes"] removeObject:[[STKUserStore store] currentUser]];
        [[[STKUserStore store] context] save:nil];
    };
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
//            reversal();
            
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [[comment post] uniqueID], @"comments", [comment uniqueID], @"like"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID] forKey:@"creator"];

        [c postWithSession:[self session] completionBlock:^(STKPostComment *obj, NSError *err) {
            if(err) {
                reversal();
            } else {
                [[[STKUserStore store] context] save:nil];
                
                [self trackLikeComment:comment];
            }
            block(obj, err);
        }];
    }];
}

- (void)unlikeComment:(STKPostComment *)comment completion:(void (^)(STKPostComment *p, NSError *err))block
{
    if(![comment uniqueID]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, nil);
        }];
        return;
    }

    [comment setLikeCount:[comment likeCount] - 1];
    [[comment mutableSetValueForKey:@"likes"] removeObject:[[STKUserStore store] currentUser]];
    
    void (^reversal)(void) = ^{
        [comment setLikeCount:[comment likeCount] + 1];
        [[comment mutableSetValueForKey:@"likes"] addObject:[[STKUserStore store] currentUser]];
        [[[STKUserStore store] context] save:nil];
    };

    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
//            reversal();
            
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [[comment post] uniqueID], @"comments", [comment uniqueID], @"unlike"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID] forKey:@"creator"];
        [c postWithSession:[self session] completionBlock:^(STKPostComment *obj, NSError *err) {
            if(err) {
                reversal();
            } else {
                [[[STKUserStore store] context] save:nil];
            }
            block(obj, err);
        }];
    }];
}

- (void)fetchLikersForPost:(STKPost *)post completion:(void (^)(NSArray *likers, NSError *err))block
{
    // needs fixin'
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [post uniqueID], @"likes"]];

        STKContainQuery *cq = [STKContainQuery containQueryForField:@"followers" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]];
        STKResolutionQuery *rq = [STKResolutionQuery resolutionQueryForField:@"likes"];
        [rq addSubquery:cq];
        [c setQueryObject:rq];
        
        [c setResolutionMap:@{@"User" : @"STKUser"}];
        [c setModelGraph:@[@[@"STKUser"]]];
        [c setContext:[[STKUserStore store] context]];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        [c getWithSession:[self session] completionBlock:^(NSArray *obj, NSError *err) {
            if(!err) {
                [post setLikes:[NSSet setWithArray:obj]];
            }
            block(obj, err);
        }];
    }];
}


- (void)addComment:(NSString *)comment toPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block
{
    STKPostComment *pc = [NSEntityDescription insertNewObjectForEntityForName:@"STKPostComment"
                                                       inManagedObjectContext:[[STKUserStore store] context]];
    [pc setCreator:[[STKUserStore store] currentUser]];
    [pc setText:comment];
    [pc setDate:[NSDate date]];
    
    [[p mutableSetValueForKey:@"comments"] addObject:pc];
    [p setCommentCount:[p commentCount] + 1];
    
    void (^reversal)(void) = ^{
        [[[STKUserStore store] context] deleteObject:pc];
        [p setCommentCount:[p commentCount] -1];
        [[[STKUserStore store] context] save:nil];
    };
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            reversal();

            block(nil, err);
            return;
        }
       
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [p uniqueID], @"comments"]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID]
                  forKey:@"creator"];
        [c addQueryValue:comment forKey:@"text"];
        
        [c setContext:[[STKUserStore store] context]];
        [c setModelGraph:@[@{@"comments" : pc}]];
        
        [c postWithSession:[self session] completionBlock:^(NSDictionary *comments, NSError *err) {
            if(err) {
                reversal();
            } else {
                [[[STKUserStore store] context] save:nil];
                
                [self trackComment:p];
            }
            block(p, err);
        }];

    }];
}

- (void)deleteComment:(STKPostComment *)comment completion:(void (^)(STKPost *p, NSError *err))block
{
    STKPost *p = [comment post];

    [p setCommentCount:[p commentCount] - 1];
    [[p mutableSetValueForKey:@"comments"] removeObject:comment];
    
    void (^reversal)(void) = ^{
        [p setCommentCount:[p commentCount] + 1];
        [[p mutableSetValueForKey:@"comments"] addObject:comment];
        [[[STKUserStore store] context] save:nil];
    };
        
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err) {
        if(err) {
            reversal();
            
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[STKContentEndpointPost, [p uniqueID], @"comments", [comment uniqueID]]];
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID]
                  forKey:@"creator"];
        
        [c deleteWithSession:[self session] completionBlock:^(id comments, NSError *err) {
            if(err) {
                reversal();
            } else {
                [[[STKUserStore store] context] deleteObject:comment];
                [[[STKUserStore store] context] save:nil];
            }
            block(p, err);
        }];
        
    }];
}

- (void)fetchRecommendedHashtags:(NSString *)baseString
                      completion:(void (^)(NSArray *suggestions))block
{
    NSPredicate *p = [NSPredicate predicateWithFormat:@"title beginswith[cd] %@", baseString];
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"STKHashTag"];
    [req setPredicate:p];
    [req setFetchLimit:5];
    [req setResultType:NSDictionaryResultType];
    [req setReturnsDistinctResults:YES];
    [req setPropertiesToFetch:@[@"title"]];
    
    NSArray *results = [[[[STKUserStore store] context] executeFetchRequest:req error:nil] valueForKey:@"title"];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block(results);
    }];
}

- (void)addPostWithInfo:(NSDictionary *)info completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }

        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/users", [[[STKUserStore store] currentUser] uniqueID], @"posts"]];
        
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID] forKey:@"creator"];
                
        for(NSString *key in info) {
            [c addQueryValue:[info objectForKey:key] forKey:key];
        }
        
        NSString *lowercaseText = [info objectForKey:STKPostTextKey];
        
        BOOL didSetVisibilityWithHashtag = NO;
        // This will set the Visibility based on hashtag triggers set in posts text
        if([lowercaseText length] > 0){
            if([lowercaseText rangeOfString:@"#public"].location != NSNotFound) {
                [c addQueryValue:STKPostVisibilityPublic forKey:STKPostVisibilityKey];
                didSetVisibilityWithHashtag = YES;
            } else if ([lowercaseText rangeOfString:@"#personal"].location != NSNotFound) {
                [c addQueryValue:STKPostVisibilityPrivate forKey:STKPostVisibilityKey];
                didSetVisibilityWithHashtag = YES;
            } else if ([lowercaseText rangeOfString:@"#trust"].location != NSNotFound) {
               [c addQueryValue:STKPostVisibilityTrust forKey:STKPostVisibilityKey];
                didSetVisibilityWithHashtag = YES;
            }
        }
        
        if(![info objectForKey:STKPostVisibilityKey] && !didSetVisibilityWithHashtag) {
            [c addQueryValue:STKPostVisibilityTrust forKey:STKPostVisibilityKey];
        }
        
        // This will wash away any Visibility modifiers as intended
        if([[info objectForKey:STKPostTypeKey] isEqualToString:STKPostTypePersonal]) {
            [c addQueryValue:STKPostVisibilityPrivate forKey:STKPostVisibilityKey];
        }
        
        
        [c setContext:[[STKUserStore store] context]];
        [c setModelGraph:@[@"STKPost"]];
        
        [c postWithSession:[self session] completionBlock:^(STKPost *post, NSError *err) {
            if(!err) {
                [post setFInverseFeed:[[STKUserStore store] currentUser]];
                [[[STKUserStore store] context] save:nil];
                
                [self trackPostCreation:post];
            } else {
                int postCount = [[[STKUserStore store] currentUser] postCount];
                [[[STKUserStore store] currentUser]  setPostCount:postCount+1];
            }
            block(post, err);
        }];
    }];
}

- (void)fetchPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/posts", [p uniqueID]]];
        
        
        STKQueryObject *q = [[STKQueryObject alloc] init];
        
        STKResolutionQuery *tagQ = [STKResolutionQuery resolutionQueryForField:@"tags"];
        [q addSubquery:tagQ];
        
        STKResolutionQuery *rq = [STKResolutionQuery resolutionQueryForField:@"creator"];
        [q addSubquery:rq];
        
        STKContainQuery *cq = [STKContainQuery containQueryForField:@"likes" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]];
        [q addSubquery:cq];
        
        [c setQueryObject:q];

        [c setResolutionMap:@{@"User" : @"STKUser"}];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        
        [c setContext:[p managedObjectContext]];
        [c setModelGraph:@[p]];
        
        [c getWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(!err) {
                [[p managedObjectContext] save:nil];
            } else {
                
            }
            
            block(obj, err);
        }];
    }];
}

- (void)editPost:(STKPost *)p completion:(void (^)(STKPost *p, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/posts", [p uniqueID]]];
        
        [c addQueryValue:[[[STKUserStore store] currentUser] uniqueID] forKey:@"creator"];
        
        NSDictionary *changedValues = [p changedValues];
        for(NSString *key in changedValues) {
            NSString *val = [changedValues objectForKey:key];
            NSString *newKey = [STKPost remoteKeyForLocalKey:key];
            if(val && newKey) {
                [c addQueryValue:[p remoteValueForLocalKey:key]
                          forKey:newKey];
            }
        }
        

        [c putWithSession:[self session] completionBlock:^(id obj, NSError *err) {
            if(!err) {
                [[p managedObjectContext] save:nil];
                [[[STKUserStore store] context] save:nil];
            } else {
                
            }
            
            block(obj, err);
        }];
    }];
}

- (void)fetchCommentsForPost:(STKPost *)post completion:(void (^)(NSArray *comments, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        // needs fixin
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/posts", [post uniqueID], @"comments"]];

        STKQueryObject *q = [[STKQueryObject alloc] init];
        [q addSubquery:[STKResolutionQuery resolutionQueryForField:@"creator"]];
        [q setFormat:@"basic"];
        [q addSubquery:[STKResolutionQuery resolutionQueryForField:@"tags"]];
//        STKResolutionQuery *tagQ = [STKResolutionQuery resolutionQueryForField:@"tags"];
//        [q addSubquery:tagQ];
        [q addSubquery:[STKContainQuery containQueryForField:@"likes" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]]];
//        [q addSubquery:rq];
        
        [c setQueryObject:q];
        
        [c setResolutionMap:@{@"User" : @"STKUser"}];
        [c setModelGraph:@[@[@"STKPostComment"]]];
        [c setExistingMatchMap:@{@"uniqueID" : @"_id"}];
        [c setContext:[[STKUserStore store] context]];
        [c getWithSession:[self session] completionBlock:^(NSArray *comments, NSError *err) {
            if(!err) {
                [post setComments:[NSSet setWithArray:comments]];
                
                [[[STKUserStore store] context] save:nil];
            } else {
                
            }
            
            block(comments, err);
        }];
    }];
}
- (void)fetchLikersForComment:(STKPostComment *)postComment completion:(void (^)(NSArray *likers, NSError *err))block
{
    // needs fixing
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/posts", [[postComment post] uniqueID], @"comments", [postComment uniqueID], @"likes"]];
        [c setModelGraph:@[@{@"likes": @[@"STKUser"]}]];
        [c setExistingMatchMap:@{@"uniqueID": @"_id"}];
        [c setContext:[[STKUserStore store] context]];
        [c getWithSession:[self session] completionBlock:^(NSDictionary *obj, NSError *err) {
            if(!err) {
                [postComment setLikes:[NSSet setWithArray:[obj objectForKey:@"likes"]]];
                [[[STKUserStore store] context] save:nil];
            }
            block([obj objectForKey:@"likes"], err);
        }];
    }];
}

- (void)trackPostCreation:(STKPost *)post
{
//    BOOL repost = NO;
//    STKUser *originalPoster = [post creator];
//    NSString *source = ([post externalProvider]) ? [post externalProvider] : @"prizm";
//    if ([post originalPost] != nil) {
//        repost = YES;
//        originalPoster = [[post originalPost] creator];
//    }
//    NSString *originalPosterIdentifier = [NSString stringWithFormat:@"%@ %@", [originalPoster name], [originalPoster uniqueID]];
//    
//    NSMutableString *hashTags = [[NSMutableString alloc] init];
//    
//    for (STKHashTag *ht in [post hashTags]) {
//        [hashTags appendString:[ht title]];
//    }
    [[Mixpanel sharedInstance] track:@"Post added" properties:mixpanelDataForObject(post)];
}

- (void)trackLikePost:(STKPost *)post
{
    NSString *targetUserIdentifier = [NSString stringWithFormat:@"%@ %@", [[post creator] name], [[post creator] uniqueID]];

    BOOL followingCreator = [[[[STKUserStore store] currentUser] following] containsObject:[post creator]];
    NSDictionary *p = @{@"post creator": targetUserIdentifier, @"following creator": @(followingCreator)};
    
    [[Mixpanel sharedInstance] track:@"Post liked" properties:mixpanelDataForObject(p)];
}

- (void)trackLikeComment:(STKPostComment *)postComment
{
    [[Mixpanel sharedInstance] track:@"Comment liked" properties:mixpanelDataForObject(postComment)];
}

- (void)trackComment:(STKPost *)post
{
    NSString *posterIdentifier = [NSString stringWithFormat:@"%@ %@", [[post creator] name], [[post creator] uniqueID]];
    
    [[Mixpanel sharedInstance] track:@"Commented on post" properties:mixpanelDataForObject(@{@"Post creator" : posterIdentifier})];
}


@end
