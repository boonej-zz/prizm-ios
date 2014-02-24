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
#import "STKProfile.h"
#import "STKFoursquareConnection.h"
#import "STKFoursquareLocation.h"

NSString * const STKContentStoreErrorDomain = @"STKContentStoreErrorDomain";

NSString * const STKContentFoursquareClientID = @"NPXBWJD343KPWSECQJM1NKJEZ4SYQ4RGRYWEBTLCU21PNUXO";
NSString * const STKContentFoursquareClientSecret = @"B2KSDXAPXQTWWMZLB2ODCCR3JOJVRQKCS1MNODYKD4TF2VCS";

NSString * const STKContentEndpointPost = @"/post";


@interface STKContentStore ()
- (void)buildTemporaryData;
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

- (NSManagedObjectContext *)context
{
    return [[STKBaseStore store] context];
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
    [[STKBaseStore store] executeAuthorizedRequest:^(BOOL granted){
        if(!granted) {
            block(nil, [NSError errorWithDomain:STKAuthenticationErrorDomain code:-1 userInfo:nil]);
            return;
        }
        
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:STKContentEndpointPost];
       /* [c addQueryObject:[u personalProfile]
              missingKeys:nil
               withKeyMap:@{@"profileID" : @"followed_by"}];*/
        [c addQueryValue:@"30" forKey:@"limit"];
        if(referencePost) {
            if(fetchDirection == STKContentStoreFetchDirectionNewer) {
                [c addQueryValue:[referencePost referenceTimestamp] forKey:@"created_min"];
            } else if(fetchDirection == STKContentStoreFetchDirectionOlder) {
                [c addQueryValue:[referencePost referenceTimestamp] forKey:@"created_max"];
            }
        } else {
            // Without a reference post, we don't have any posts so we just need to grab off the top of the stack
            
        }

        [c setModelGraph:@{@"post" : @[@"STKPost"]}];
        [c getWithSession:[self session] completionBlock:^(NSDictionary *obj, NSError *err) {
            if(!err) {
                NSArray *posts = [obj objectForKey:@"post"];
                
                block(posts, nil);
            } else {
                block(nil, err);
            }
        }];
    }];
}

- (void)fetchExplorePostsInDirection:(STKContentStoreFetchDirection)fetchDirection
                       referencePost:(STKPost *)referencePost
                          completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(BOOL granted){
        if(!granted) {
            block(nil, [NSError errorWithDomain:STKAuthenticationErrorDomain code:-1 userInfo:nil]);
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

- (void)fetchProfilePostsForUserID:(NSString *)userID
                       inDirection:(STKContentStoreFetchDirection)fetchDirection
                     referencePost:(STKPost *)referencePost
                        completion:(void (^)(NSArray *posts, NSError *err))block
{
    [[STKBaseStore store] executeAuthorizedRequest:^(BOOL granted){
        if(!granted) {
            block(nil, [NSError errorWithDomain:STKAuthenticationErrorDomain code:-1 userInfo:nil]);
            return;
        }
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/users"];
        [c setIdentifiers:@[userID, @"posts"]];
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
    [[STKBaseStore store] executeAuthorizedRequest:^(BOOL granted){
        if(!granted) {
            block(nil, [NSError errorWithDomain:STKAuthenticationErrorDomain code:-1 userInfo:nil]);
            return;
        }
        NSLog(@"Posting: %@", info);
        STKConnection *c = [[STKBaseStore store] connectionForEndpoint:@"/users"];
        [c setIdentifiers:@[[[[STKUserStore store] currentUser] userID], @"posts"]];
        [c addQueryValue:@"public" forKey:@"scope"];
        [c addQueryValue:[[[STKUserStore store] currentUser] userID] forKey:@"creator"];
        
        for(NSString *key in info) {
            [c addQueryValue:[info objectForKey:key] forKey:key];
        }
        
        [c postWithSession:[self session] completionBlock:^(id obj, NSError *err) {

            if(!err) {
                    // Should catch, but you know, can't yet
            } else {
            
            }
            
            block(obj, err);
        }];
    }];
}

- (void)buildTemporaryData
{/*
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:@"STKUser"];
    NSArray *a = [[self context] executeFetchRequest:r error:nil];
    if([a count] > 0) {
        [[STKUserStore store] setCurrentUser:[a objectAtIndex:0]];
        return;
    }
    
    STKUser *u = [NSEntityDescription insertNewObjectForEntityForName:@"STKUser"
                                               inManagedObjectContext:[self context]];
    [u setUserID:0];
    [u setUserName:@"Cedric Rogers"];
    [u setEmail:@"cedric@higheraltitude.co"];
    [u setGender:@"Male"];
    
    [[STKUserStore store] setCurrentUser:u];
    
    // reuqestItes, activityItems, posts
    
    NSArray *authors = @[@"University of Wisconsin", @"Cedric Rogers", @"Joe Conway", @"Rovane Durso",
                         @"Facebook", @"North Carolina State", @"Emory"];
    NSArray *iconURLStrings = @[@"https://www.etsy.com/storque/media/bunker/2008/10/DU_Wisconsin_logo-tn.jpg",
                                @"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg",
                                @"http://stablekernel.com/images/joe.png",
                                @"https://pbs.twimg.com/profile_images/3500227034/2ad776b09c64e9ff677c91dd55a18472_bigger.jpeg",
                                @"http://marketingland.com/wp-content/ml-loads/2013/05/facebook-logo-new-300x300.png",
                                @"http://www.logotypes101.com/logos/953/28D5E04946B566AA97E4770658F48F55/NC_State_University1.png",
                                @"http://www.comacc.org/training/PublishingImages/Emory_Logo.jpg"];
    
    NSArray *origins = @[@"Instagram", @"Facebook", @"Prism", @"Twitter"];
    NSArray *dates = @[[NSDate date], [NSDate dateWithTimeIntervalSinceNow:-100000], [NSDate dateWithTimeIntervalSinceNow:-2000]];
    NSArray *images = @[@"http://socialmediamamma.com/wp-content/uploads/2012/11/now-is-the-time-inspirational-quote-inspiring-quotes-www.socialmediamamma.com_.jpg",
                        @"http://socialmediamamma.com/wp-content/uploads/2012/11/dont-be-afraid-to-live-inspiring-quotes-Inspirational-quotes-Gaynor-Parke-www.socialmediamamma.com_.jpg"];
    
    NSArray *hashTags = @[@"hash", @"tag", @"bar", @"foo", @"baz", @"school", @"inspiration"];
    
    srand(time(NULL));
    
    for(int i = 0; i < 10; i++) {
        STKPost *p = [NSEntityDescription insertNewObjectForEntityForName:@"STKPost"
                                                   inManagedObjectContext:[self context]];
        int idx = rand() % [authors count];
        [p setAuthorName:authors[idx]];
        [p setIconURLString:iconURLStrings[idx]];
        
        idx = rand() % [origins count];
        [p setPostOrigin:origins[idx]];
        
        [p setAuthorUserID:0];
        
        idx = rand() % [dates count];
        [p setDatePosted:dates[idx]];
        
        int count = rand() % 4;
        NSMutableArray *tags = [NSMutableArray array];
        for(int j = 0; j < count; j++) {
            idx = rand() % [hashTags count];
            [tags addObject:hashTags[idx]];
        }
        [p setHashTagsData:[NSJSONSerialization dataWithJSONObject:tags options:0 error:nil]];
        
        idx = rand() % [images count];
        [p setImageURLString:images[idx]];
        
        [p setType:rand() % (STKPostTypeAccolade + 1)];
        
        [p setUser:u];
    }
    
    for(int i = 0; i < 5; i++) {
        STKActivityItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"STKActivityItem"
                                                              inManagedObjectContext:[self context]];
        [item setUser:u];
        [item setUserID:0];
        [item setUserName:@"Cedric Rogers"];
        [item setProfileImageURLString:@"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg"];
        [item setRecent:(BOOL)(rand() % 2)];
        [item setType:(STKActivityItemType)(rand() % 5)];
        [item setReferenceImageURLString:images[rand() % [images count]]];
        [item setDate:dates[rand() % [dates count]]];
    }
    for(int i = 0; i < 5; i++) {
        STKRequestItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"STKRequestItem"
                                                             inManagedObjectContext:[self context]];
        [item setUser:u];
        [item setUserID:0];
        [item setUserName:@"Cedric Rogers"];
        [item setProfileImageURLString:@"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg"];
        [item setType:STKRequestItemTypeTrust];
        [item setDateReceived:dates[rand() % [dates count]]];
        if(rand() % 2 == 0) {
            [item setAccepted:(BOOL)(rand() % 2)];
            [item setDateConfirmed:dates[rand() % [dates count]]];
        }
        
    }
    [[self context] save:nil];*/
}

@end
