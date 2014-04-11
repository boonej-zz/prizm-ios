//
//  STKNetworkStore.m
//  Prism
//
//  Created by Joe Conway on 4/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKNetworkStore.h"
#import "STKBaseStore.h"
#import "STKImageStore.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKContentStore.h"
#import "STKPost.h"
@import Accounts;

@interface STKNetworkStore ()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation STKNetworkStore
+ (STKNetworkStore *)store
{
    static STKNetworkStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKNetworkStore alloc] init];
    });
    
    return store;
}


- (id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (void)checkAndFetchPostsFromOtherNetworksForUser:(STKUser *)user
                                        completion:(void (^)(STKUser *updatedUser, NSError *err))block
{
    [[STKUserStore store] fetchUserDetails:user additionalFields:@[@"instagram_token", @"instagram_min_id", @"twitter_min_id", @"twitter_token"] completion:^(STKUser *user, NSError *err) {
/*       [self transferPostsFromInstagramWithToken:[user instagramToken] lastMinimumID:[user instagramLastMinID] completion:^(NSString *lastID, NSError *err) {
            [self transferPostsFromTwitterAccount:<#(ACAccount *)#> completion:<#^(NSString *lastID, NSError *err)block#>]
        }];*/
        if([user twitterID]) {
            ACAccount *twitterAccount = [[[STKUserStore store] accountStore] accountWithIdentifier:[user twitterID]];
            NSLog(@"%@", twitterAccount);
        }
    }];
}


- (void)transferPostsFromInstagramWithToken:(NSString *)token
                              lastMinimumID:(NSString *)minID
                                 completion:(void (^)(NSString *lastID, NSError *err))block
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@&count=20", token];
    if(minID) {
        urlString = [urlString stringByAppendingFormat:@"&min_id=%@", minID];
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionDataTask *dt = [[[STKBaseStore store] session] dataTaskWithRequest:req
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                     if(!error) {
                                                                         NSDictionary *val = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                                             NSMutableArray *postsToSend = [NSMutableArray array];
                                                                             NSArray *posts = [val objectForKey:@"data"];
                                                                             for(NSDictionary *post in posts) {
                                                                                 NSString *postID = [post objectForKey:@"id"];
                                                                                 if([postID isEqualToString:minID])
                                                                                     continue;
                                                                                 
                                                                                 if([[post objectForKey:@"type"] isEqualToString:@"image"]) {
                                                                                     if([[post objectForKey:@"tags"] containsObject:@"prizm"]) {
                                                                                         [postsToSend addObject:post];
                                                                                     }
                                                                                 }
                                                                             }
                                                                             
                                                                             // Now go ahead and push this up
                                                                             NSString *firstID = [[posts firstObject] objectForKey:@"id"];
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 block(firstID, nil);
                                                                                 [self createPostsFromInstagram:postsToSend];
                                                                             });
                                                                             
                                                                         });
                                                                     } else {
                                                                         block(nil, error);
                                                                     }
                                                                 }];
    [dt resume];
    
}

- (void)createPostsFromInstagram:(NSArray *)posts
{
    if([posts count] == 0)
        return;
    
    NSDictionary *post = [posts lastObject];
    
    NSString *text = [[post objectForKey:@"caption"] objectForKey:@"text"];
    NSDictionary *images = [post objectForKey:@"images"];
    NSDictionary *normalImage = [images objectForKey:@"standard_resolution"];
    NSString *link = [post objectForKey:@"link"];
    NSString *urlString = [normalImage objectForKey:@"url"];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    if(!text)
        text = @"";
    if(!link)
        link = @"";
    
    NSURLSessionDataTask *dt = [[[STKBaseStore store] session] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error) {
            UIImage *img = [UIImage imageWithData:data];
            if(img) {
                [[STKImageStore store] uploadImage:img thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
                    
                    NSDictionary *postInfo = @{
                                               STKPostTextKey : text,
                                               STKPostURLKey : URLString,
                                               STKPostTypeKey : STKPostTypeExperience,
                                               @"external_provider" : @"instagram",
                                               @"external_link" : link
                                               };
                    
                    [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
                        if(!err) {
                            NSMutableArray *a = [posts mutableCopy];
                            [a removeLastObject];
                            [self createPostsFromInstagram:a];
                        }
                    }];
                }];
            }
        }
    }];
    [dt resume];
}

- (void)transferPostsFromTwitterAccount:(ACAccount *)account
                             completion:(void (^)(NSString *lastID, NSError *err))block
{
    [[STKUserStore store] fetchTwitterAccessToken:account completion:^(NSString *token, NSString *tokenSecret, NSError *err) {
        if(err) {
            block(nil, err);
        } else {
            SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET
                                                          URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"]
                                                   parameters:@{@"trim_user" : @"true",
                                                                @"include_rts" : @"false"}];
            [req setAccount:account];
            
            [NSURLConnection sendAsynchronousRequest:[req preparedURLRequest] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if(connectionError) {
                    block(nil, connectionError);
                } else {
                    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                    NSLog(@"%@", json);
                    NSMutableArray *postsToSend = [NSMutableArray array];
                    for(NSDictionary *d in json) {
                        NSDictionary *entities = [d objectForKey:@"entities"];
                        NSArray *hashTags = [entities objectForKey:@"hashtags"];
                        for(NSDictionary *hashTag in hashTags) {
                            if([[hashTag objectForKey:@"text"] isEqualToString:@"prizm"]) {
                                [postsToSend addObject:d];
                            }
                        }
                    }
                    
                    [self createPostsForTwitter:postsToSend];
                    
                    // Sync up all that other shit
                    block(nil, nil);
                }
            }];

        }
    }];
}

- (void)createPostsForTwitter:(NSArray *)posts
{
    for(NSDictionary *post in posts) {
        NSString *text = [post objectForKey:@"text"];
        NSString *userID = [[post objectForKey:@"user"] objectForKey:@"id"];
        NSString *tweetID = [post objectForKey:@"id"];
        NSString *link = [NSString stringWithFormat:@"http://twitter.com/%@/status/%@", userID, tweetID];

        NSDictionary *postInfo = @{
                                   STKPostTextKey : text,
                                   STKPostTypeKey : STKPostTypeExperience,
                                   @"external_provider" : @"twitter",
                                   @"external_link" : link
                                   };
        
        [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
            if(!err) {
                NSMutableArray *a = [posts mutableCopy];
                [a removeLastObject];
                [self createPostsForTwitter:a];
            }
        }];

    }
    
    
}


@end
