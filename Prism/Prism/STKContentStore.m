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
#import "STKPostComment.h"
#import "STKFetchDescription.h"

NSString * const STKContentStoreErrorDomain = @"STKContentStoreErrorDomain";

NSString * const STKContentFoursquareClientID = @"NPXBWJD343KPWSECQJM1NKJEZ4SYQ4RGRYWEBTLCU21PNUXO";
NSString * const STKContentFoursquareClientSecret = @"B2KSDXAPXQTWWMZLB2ODCCR3JOJVRQKCS1MNODYKD4TF2VCS";

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
        [req setFetchLimit:30];
        
        return [[[STKUserStore store] context] executeFetchRequest:req error:nil];
    } else {
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"STKPost"];
        [req setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
        [req setFetchLimit:30];
        
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
/*    NSArray *cached = [self cachedPostsForPredicate:[NSPredicate predicateWithFormat:@"fInverseFeed == %@", [[STKUserStore store] currentUser]]
                                   fetchDescription:desc];

    STKPost *referencePost = [desc referenceObject];
    if([cached count] > 0) {
        BOOL returnAfter = NO;
        
        if([desc direction] == STKQueryObjectPageNewer) {
            referencePost = [cached firstObject];
        } else if ([desc direction] == STKQueryObjectPageOlder) {
            // If we have 30 posts, then just skip pulling these from the server
            if([cached count] == 30) {
                referencePost = nil;
                returnAfter = YES;
            } else {
                referencePost = [cached lastObject];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(cached, nil);
        }];
        if(returnAfter)
            return;
    }*/
    
    [[STKBaseStore store] executeAuthorizedRequest:^(NSError *err){
        if(err) {
            block(nil, err);
            return;
        }
                
        STKConnection *c = [[STKBaseStore store] newConnectionForIdentifiers:@[@"/users", [u uniqueID], @"feed"]];
        
        STKQueryObject *q = [[STKQueryObject alloc] init];
        [q setLimit:30];
        [q setPageDirection:[desc direction]];
        [q setPageKey:STKPostDateCreatedKey];
        [q setPageValue:[STKTimestampFormatter stringFromDate:[[desc referenceObject] datePosted]]];
        
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
                //[[[[STKUserStore store] currentUser] mutableSetValueForKeyPath:@"fFeedPosts"] addObjectsFromArray:posts];
                [[[STKUserStore store] context] save:nil];
                block(posts, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
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
        [q setLimit:30];
        if([desc referenceObject]) {
            [q setPageDirection:[desc direction]];
            [q setPageKey:STKPostDateCreatedKey];
            [q setPageValue:[STKTimestampFormatter stringFromDate:[(STKPost *)[desc referenceObject] datePosted]]];
        }

        [q setFilters:[self serverFilterMapFromLocalFilterMap:[desc filterDictionary]]];
        
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
            reversal();
            
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
            reversal();
            
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
        if(![info objectForKey:STKPostVisibilityKey]) {
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
        [q addSubquery:[STKContainQuery containQueryForField:@"likes" key:@"_id" value:[[[STKUserStore store] currentUser] uniqueID]]];
        
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


@end
