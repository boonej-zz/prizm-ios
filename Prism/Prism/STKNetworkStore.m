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
#import "STKMarkupUtilities.h"
#import "TMAPIClient.h"

@import Accounts;

const int STKNetworkStoreErrorTwitterAccountNoLongerExists = -25;
NSString * const STKNetworkStoreTumblrSyncInfoKey = @"STKNetworkStoreTumblrSyncInfoKey";

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
    } else if(type == STKNetworkTypeTumblr) {
        //establish minimum id
        [[TMAPIClient sharedInstance] userInfo:^(NSDictionary* response, NSError *error) {
            if (!error) {
                NSArray *blogs = response[@"user"][@"blogs"];
                NSMutableArray *hosts = [NSMutableArray array];
                for (NSDictionary *blog in blogs) {
                    NSURL *url = [NSURL URLWithString:blog[@"url"]];
                    NSString *host = [url host];
                    [hosts addObject:host];
                }
                
                __block NSUInteger hostCount = [hosts count];
                __block NSMutableArray *posts = [NSMutableArray array];
                for (NSString *host in hosts) {
                    [[TMAPIClient sharedInstance] posts:host type:nil parameters:nil callback:^(NSDictionary *response, NSError *error) {
                        if (!error) {
                            hostCount--;
                            NSLog(@"post at host response\n%@", response);
                            [posts addObjectsFromArray:response[@"posts"]];
                            if (hostCount == 0) {
                                // all posts of all types gathered (we don't need to filter here, because we just want the most
                                // recent date
                                
                                NSArray *sortedPosts = [posts sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
                                [sortedPosts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                    NSLog(@"tumblr date %@", obj[@"date"]);
                                }];
                                NSDictionary *lastMins = @{@"date" : [sortedPosts firstObject][@"date"],
                                                           @"hosts" : hosts};
                                [[NSUserDefaults standardUserDefaults] setObject:lastMins forKey:STKNetworkStoreTumblrSyncInfoKey];
                                
                                block([sortedPosts firstObject][@"date"], error);
                            }
                        } else {
                            block(nil, error);
                        }
                    }];
                }
            } else {
                block(nil, error);
            }
        }];
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
    
    STKUser *u = [[STKUserStore store] currentUser];
    if(!u) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(nil, nil);
        }];
        return;
    }
    
    [self setUpdating:YES];
    
    [[STKUserStore store] fetchUserDetails:u additionalFields:@[@"instagram_token", @"instagram_min_id", @"twitter_min_id", @"twitter_token", @"tumblr_token", @"tumblr_min_id"] completion:^(STKUser *user, NSError *err) {
        if(!err) {
            NSLog(@"Will check Instagram %@", [user instagramToken]);
            [self transferPostsFromInstagramWithToken:[user instagramToken] lastMinimumID:[u instagramLastMinID] completion:^(NSString *instagramLastID, NSError *err) {
                if(!err)
                    [u setInstagramLastMinID:instagramLastID];
                
                [[STKUserStore store] fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
                    ACAccount *account = [self matchingAccountForUser:u inAccounts:accounts];
                    NSLog(@"Will check Twitter %@", [account username]);
                    [self transferPostsFromTwitterAccount:account lastMinimumID:[u twitterLastMinID] completion:^(NSString *twitterLastID, NSError *twitterError) {
                        if([twitterError code] == STKNetworkStoreErrorTwitterAccountNoLongerExists) {
                            [u setTwitterID:nil];
                        }
                        if(!err)
                            [u setTwitterLastMinID:twitterLastID];

                        [self transferPostsFromTumblrWithToken:[u tumblrToken] secret:[u tumblrTokenSecret] lastMinimumID:[u tumblrLastMinID] completion:^(NSString *tumblrLastID, NSError *err) {
                            if (!err)
                                [u setTumblrLastMinID:tumblrLastID];
                                
                            [self setUpdating:NO];
                            
                            block(u, nil);
                        }];
                    }];
                }];
            }];
        } else {
            NSLog(@"Failed to get instagram/twitter/tumblr details");
        }
    }];
}


- (void)transferPostsFromInstagramWithToken:(NSString *)token
                              lastMinimumID:(NSString *)minID
                                 completion:(void (^)(NSString *lastID, NSError *err))block
{
    if(!token) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(minID, nil);
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
                                                                                     for(NSString *tag in [post objectForKey:@"tags"]) {
                                                                                         if([[tag lowercaseString] isEqualToString:@"prizm"]) {
                                                                                             [postsToSend addObject:post];
                                                                                         }
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
                                                                         block(minID, error);
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
    
    NSString *postType = STKPostTypeExperience;
    NSString *lowercaseSearchString = [text lowercaseString];
    if([lowercaseSearchString rangeOfString:@"#aspiration"].location != NSNotFound) {
        postType = STKPostTypeAspiration;
    } else if([lowercaseSearchString rangeOfString:@"#inspiration"].location != NSNotFound) {
        postType = STKPostTypeInspiration;
    } else if([lowercaseSearchString rangeOfString:@"#experience"].location != NSNotFound) {
        postType = STKPostTypeExperience;
    } else if([lowercaseSearchString rangeOfString:@"#achievement"].location != NSNotFound) {
        postType = STKPostTypeAchievement;
    } else if([lowercaseSearchString rangeOfString:@"#passion"].location != NSNotFound) {
        postType = STKPostTypePassion;
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
                                               STKPostTypeKey : postType,
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
            block(minID, [NSError errorWithDomain:@"STKNetworkStoreErrorDomain" code:STKNetworkStoreErrorTwitterAccountNoLongerExists userInfo:nil]);
        }];
        return;
    }

    [[STKUserStore store] fetchTwitterAccessToken:account completion:^(NSString *token, NSString *tokenSecret, NSError *err) {
        if(err) {
            block(minID, err);
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
                            if([[[hashTag objectForKey:@"text"] lowercaseString] isEqualToString:@"prizm"]) {
                                [postsToSend addObject:d];
                            }
                        }
                    }
                    
                    [self createPostsForTwitter:postsToSend];
                    
                    if([json count] > 0) {
                        NSString *n = [[[json sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id_str" ascending:NO]]] firstObject] objectForKey:@"id_str"];
                        if(n && ![n isKindOfClass:[NSNull class]]) {
                            block(n, nil);
                        } else {
                            block(minID, nil);
                        }
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
    
    NSString *postType = STKPostTypeExperience;
    NSString *lowercaseSearchString = [text lowercaseString];
    if([lowercaseSearchString rangeOfString:@"#aspiration"].location != NSNotFound) {
        postType = STKPostTypeAspiration;
    } else if([lowercaseSearchString rangeOfString:@"#inspiration"].location != NSNotFound) {
        postType = STKPostTypeInspiration;
    } else if([lowercaseSearchString rangeOfString:@"#experience"].location != NSNotFound) {
        postType = STKPostTypeExperience;
    } else if([lowercaseSearchString rangeOfString:@"#achievement"].location != NSNotFound) {
        postType = STKPostTypeAchievement;
    } else if([lowercaseSearchString rangeOfString:@"#passion"].location != NSNotFound) {
        postType = STKPostTypePassion;
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
                                                       STKPostTypeKey : postType,
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
        UIImage *img = [STKMarkupUtilities imageForText:text];
        [[STKImageStore store] uploadImage:img thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
            if(!err) {
                NSDictionary *postInfo = @{
                                           STKPostTextKey : text,
                                           STKPostTypeKey : postType,
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

- (void)transferPostsFromTumblrWithToken:(NSString *)token
                                secret:(NSString *)secret
                           lastMinimumID:(NSString *)minID
                              completion:(void (^)(NSString *lastID, NSError *err))block
{
    if(!token) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(minID, nil);
        }];
        return;
    }
    
}

@end
