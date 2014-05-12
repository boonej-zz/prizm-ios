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

const int STKNetworkStoreErrorTwitterAccountNoLongerExists = -25;

@interface STKNetworkStore ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic) BOOL updating;
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

- (ACAccount *)matchingAccountForUser:(STKUser *)u inAccounts:(NSArray *)accounts
{
    for(ACAccount *a in accounts) {
        if([[a username] isEqualToString:[u twitterID]]) {
            return a;
        }
    }
    return nil;
}

- (void)establishMinimumIDForUser:(STKUser *)u networkType:(STKNetworkType)type completion:(void (^)(NSString *minID, NSError *err))block
{
    if(type == STKNetworkTypeTwitter) {
        [[STKUserStore store] fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
            ACAccount *account = [self matchingAccountForUser:u inAccounts:accounts];
            if(account) {
                NSMutableDictionary *params = [@{@"trim_user" : @"true", @"count" : @(1)} mutableCopy];
                SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"]
                                                       parameters:params];
                
                [req setAccount:account];
                
                [NSURLConnection sendAsynchronousRequest:[req preparedURLRequest] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if(connectionError) {
                        block(nil, connectionError);
                    } else {
                        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        NSString *n = [[[json sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id_str" ascending:NO]]] firstObject] objectForKey:@"id_str"];
                        block(n, nil);
                    }
                }];
            }
        }];
    } else if(type == STKNetworkTypeInstagram) {
        NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@&count=1", [u instagramToken]];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        NSURLSessionDataTask *dt = [[[STKBaseStore store] session] dataTaskWithRequest:req
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         if(!error) {
                                                                             NSDictionary *val = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                             NSArray *posts = [val objectForKey:@"data"];
                                                                             
                                                                             // Now go ahead and push this up
                                                                             NSArray *sorted = [posts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:NO]]];
                                                                             NSString *firstID = [[sorted firstObject] objectForKey:@"created_time"];
                                                                             block(firstID, nil);
                                                                         } else {
                                                                             block(nil, error);
                                                                         }
                                                                     }];
        [dt resume];
    }
}

- (void)checkAndFetchPostsFromOtherNetworksForCurrentUserCompletion:(void (^)(STKUser *updatedUser, NSError *err))block
{
    if([self updating]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, nil);
        }];
        return;
    }
    
    [self setUpdating:YES];
    
    [[STKUserStore store] fetchUserDetails:[[STKUserStore store] currentUser] additionalFields:@[@"instagram_token", @"instagram_min_id", @"twitter_min_id", @"twitter_token"] completion:^(STKUser *user, NSError *err) {
        if(!err) {
            NSLog(@"Will check Instagram %@", [user instagramToken]);
            [self transferPostsFromInstagramWithToken:[user instagramToken] lastMinimumID:[[[STKUserStore store] currentUser] instagramLastMinID] completion:^(NSString *instagramLastID, NSError *err) {
                [[[STKUserStore store] currentUser] setInstagramLastMinID:instagramLastID];
                
                [[STKUserStore store] fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
                    ACAccount *account = [self matchingAccountForUser:[[STKUserStore store] currentUser] inAccounts:accounts];
                    NSLog(@"Will check Twitter %@", [account username]);
                    [self transferPostsFromTwitterAccount:account lastMinimumID:[[[STKUserStore store] currentUser] twitterLastMinID] completion:^(NSString *twitterLastID, NSError *twitterError) {
                        if([twitterError code] == STKNetworkStoreErrorTwitterAccountNoLongerExists) {
                            [[[STKUserStore store] currentUser] setTwitterID:nil];
                        }
                        [[[STKUserStore store] currentUser] setTwitterLastMinID:twitterLastID];

                        [self setUpdating:NO];
                        
                        block([[STKUserStore store] currentUser], nil);
                    }];
                }];
            }];
        } else {
            NSLog(@"Failed to get instagram/twitter details");
        }
    }];
}


- (void)transferPostsFromInstagramWithToken:(NSString *)token
                              lastMinimumID:(NSString *)minID
                                 completion:(void (^)(NSString *lastID, NSError *err))block
{
    if(!token) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, nil);
        }];
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@&count=20", token];
    if(minID) {
        NSInteger v = [minID integerValue] + 1;
        urlString = [urlString stringByAppendingFormat:@"&min_timestamp=%d", v];
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionDataTask *dt = [[[STKBaseStore store] session] dataTaskWithRequest:req
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                     if(!error) {
                                                                         NSDictionary *val = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                                             NSMutableArray *postsToSend = [NSMutableArray array];
                                                                             NSArray *posts = [val objectForKey:@"data"];
                                                                             NSLog(@"Instagram yielded %d total posts", [posts count]);
                                                                             for(NSDictionary *post in posts) {
                                                                                 
                                                                                 if([[post objectForKey:@"type"] isEqualToString:@"image"]) {
                                                                                     if([[post objectForKey:@"tags"] containsObject:@"prizm"]) {
                                                                                         [postsToSend addObject:post];
                                                                                     }
                                                                                 }
                                                                             }
                                                                             
                                                                             // Now go ahead and push this up
                                                                             NSArray *sorted = [posts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:NO]]];
                                                                             NSString *firstID = [[sorted firstObject] objectForKey:@"created_time"];
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 if(firstID)
                                                                                     block(firstID, nil);
                                                                                 else
                                                                                     block(minID, nil);
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
    if([post isKindOfClass:[NSNull class]]) {
        NSMutableArray *a = [posts mutableCopy];
        [a removeLastObject];
        [self createPostsFromInstagram:a];
        return;
    }
    
    NSString *link = [post objectForKey:@"link"];
    NSDictionary *caption = [post objectForKey:@"caption"];
    NSString *text = nil;
    if(![caption isKindOfClass:[NSNull class]]) {
        text = [caption objectForKey:@"text"];
    }
    NSDictionary *images = [post objectForKey:@"images"];
    NSString *urlString = nil;
    if([images isKindOfClass:[NSDictionary class]]) {
        NSDictionary *normalImage = [images objectForKey:@"standard_resolution"];
        if([normalImage isKindOfClass:[NSDictionary class]]) {
            urlString = [normalImage objectForKey:@"url"];
        }
    }
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
                          lastMinimumID:(NSString *)minID
                             completion:(void (^)(NSString *lastID, NSError *err))block
{
    if(!account) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, [NSError errorWithDomain:@"STKNetworkStoreErrorDomain" code:STKNetworkStoreErrorTwitterAccountNoLongerExists userInfo:nil]);
        }];
        return;
    }

    [[STKUserStore store] fetchTwitterAccessToken:account completion:^(NSString *token, NSString *tokenSecret, NSError *err) {
        if(err) {
            block(nil, err);
        } else {
            
            NSMutableDictionary *params = [@{@"trim_user" : @"true"} mutableCopy];
            if(minID) {
                [params setObject:minID forKey:@"since_id"];
            }
            SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET
                                                          URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"]
                                                   parameters:params];
            [req setAccount:account];
            
            [NSURLConnection sendAsynchronousRequest:[req preparedURLRequest] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if(connectionError) {
                    block(nil, connectionError);
                } else {
                    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"Twitter got %d total posts", [json count]);
                    
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
                    
                    if([json count] > 0) {
                        NSString *n = [[[json sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id_str" ascending:NO]]] firstObject] objectForKey:@"id_str"];
                        block(n, nil);
                    } else {
                        block(minID, nil);
                    }
                }
            }];
            
        }
    }];
}

- (void)createPostsForTwitter:(NSArray *)posts
{
    NSDictionary *post = [posts lastObject];
    if(!post)
        return;
    
    NSString *text = [post objectForKey:@"text"];
    NSString *userID = [[post objectForKey:@"user"] objectForKey:@"id"];
    NSString *tweetID = [post objectForKey:@"id"];
    NSString *link = [NSString stringWithFormat:@"http://twitter.com/%@/status/%@", userID, tweetID];
    
    NSArray *media = [[post objectForKey:@"entities"] objectForKey:@"media"];
    NSDictionary *firstObject = [media firstObject];
    NSString *imageURL = nil;
    if([[firstObject objectForKey:@"type"] isEqualToString:@"photo"]) {
        imageURL = [firstObject objectForKey:@"media_url"];
    }
    
    
    if(imageURL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        NSURLSessionDataTask *dt = [[[STKBaseStore store] session] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(!error) {
                UIImage *img = [UIImage imageWithData:data];
                if(img) {
                    [[STKImageStore store] uploadImage:img thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
                        if(!err) {
                            NSDictionary *postInfo = @{
                                                       STKPostTextKey : text,
                                                       STKPostTypeKey : STKPostTypeExperience,
                                                       @"external_provider" : @"twitter",
                                                       @"external_link" : link,
                                                       STKPostURLKey : URLString
                                                       };
                            
                            [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
                                if(!err) {
                                    NSMutableArray *a = [posts mutableCopy];
                                    [a removeLastObject];
                                    [self createPostsForTwitter:a];
                                }
                            }];
                        }

                    }];
                }
            }
        }];
        [dt resume];
    } else {
        UIImage *img = [STKPost imageForTextPost:text];
        [[STKImageStore store] uploadImage:img thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
            if(!err) {
                NSDictionary *postInfo = @{
                                           STKPostTextKey : text,
                                           STKPostTypeKey : STKPostTypeExperience,
                                           @"external_provider" : @"twitter",
                                           @"external_link" : link,
                                           STKPostURLKey : URLString
                                           };
                
                [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
                    if(!err) {
                        NSMutableArray *a = [posts mutableCopy];
                        [a removeLastObject];
                        [self createPostsForTwitter:a];
                    }
                }];
            }
        }];
    }
}


@end
