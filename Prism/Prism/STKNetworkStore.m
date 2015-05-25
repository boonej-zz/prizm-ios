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
//#import "TMAPIClient.h"
#import "HAShareExtensionHelper.h"

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
    } else if(type == STKNetworkTypeTumblr) {
/*        //establish minimum id
        [[TMAPIClient sharedInstance] userInfo:^(NSDictionary* response, NSError *error) {
            if (!error) {
                NSArray *blogs = response[@"user"][@"blogs"];
                
                __block NSUInteger hostCount = [blogs count];
                __block NSMutableArray *posts = [NSMutableArray array];
                for (NSDictionary *blog in blogs) {
                    NSURL *url = [NSURL URLWithString:blog[@"url"]];
                    NSString *host = [url host];
                    [[TMAPIClient sharedInstance] posts:host type:nil parameters:@{@"limit" : @(1)} callback:^(NSDictionary *response, NSError *error) {
                        if (!error) {
                            hostCount--;
                            [posts addObjectsFromArray:response[@"posts"]];
                            if (hostCount == 0) {
                                // all posts of all types gathered (we don't need to filter here, because we just want the most
                                // recent date
                                NSArray *sortedPosts = [posts sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
                                
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
 */
    }
}

- (void)checkAndFetchPostsFromOtherNetworksForCurrentUserCompletion:(void (^)(NSDictionary *updatedUserData, NSError *err))block
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
    
    [[HAShareExtensionHelper helper] checkForUserDefaults];
    [[HAShareExtensionHelper helper] createPostsFromDefaults];
    
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    [[STKUserStore store] fetchUserDetails:u additionalFields:@[@"instagram_token", @"instagram_min_id", @"twitter_min_id", @"twitter_token", @"tumblr_token", @"tumblr_min_id"] completion:^(STKUser *user, NSError *err) {
        if(!err) {
//            NSLog(@"Will check Instagram %@", [user instagramToken]);
            [self transferPostsFromInstagramWithToken:[user instagramToken] lastMinimumID:[u instagramLastMinID] completion:^(NSString *instagramLastID, NSError *err) {
                if(!err && instagramLastID)
                    [stats setObject:instagramLastID forKey:@"instagramLastMinID"];
                
                [[STKUserStore store] fetchAvailableTwitterAccounts:^(NSArray *accounts, NSError *err) {
                    ACAccount *account = [self matchingAccountForUser:u inAccounts:accounts];
//                    NSLog(@"Will check Twitter %@", [account username]);
                    [self transferPostsFromTwitterAccount:account lastMinimumID:[u twitterLastMinID] completion:^(NSString *twitterLastID, NSError *twitterError) {

                        if(!err && twitterLastID)
                            [stats setObject:twitterLastID forKey:@"twitterLastMinID"];

                        [self setUpdating:NO];
                        
                        block(stats, nil);
                        /*
                        [self transferPostsFromTumblrWithLastMinimumID:[u tumblrLastMinID] completion:^(NSString *tumblrLastID, NSError *err) {
                            if (!err)
                                [u setTumblrLastMinID:tumblrLastID];
                                
                            [self setUpdating:NO];
                            
                            block(u, nil);
                        }];
                         */
                    }];
                }];
            }];
        } else {
            block(nil, err);
//            NSLog(@"Failed to get instagram/twitter/tumblr details");
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
        urlString = [urlString stringByAppendingFormat:@"&min_timestamp=%d", (int)v];
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionDataTask *dt = [[[STKBaseStore store] session] dataTaskWithRequest:req
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                     if(!error) {
                                                                         NSDictionary *val = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                                             NSMutableArray *postsToSend = [NSMutableArray array];
                                                                             NSArray *posts = [val objectForKey:@"data"];
//                                                                             NSLog(@"Instagram yielded %d total posts", (int)[posts count]);
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

    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"#prizm(?:[@#\\s]|$)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [exp matchesInString:text options:kNilOptions range:NSMakeRange(0, [text length])];
    // modify the string backwards
    int lastIndex = (int)[matches count] - 1;
    for (int i = lastIndex; i >= 0; i--) {
        NSTextCheckingResult *match = matches[i];
        NSRange hRange = NSMakeRange([match range].location, 1);
        text = [text stringByReplacingCharactersInRange:hRange withString:@""];
    }
    
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
                                               @"external_link" : link,
                                               STKPostVisibilityKey : STKPostVisibilityPublic
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
//                    NSLog(@"Twitter got %d total posts", (int)[json count]);
                    
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

    // don't include #prizm in the post (it will make #prizm trend through the roof)
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"#prizm(?:[@#\\s]|$)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [exp matchesInString:text options:kNilOptions range:NSMakeRange(0, [text length])];
    // modify the string backwards
    int lastIndex = (int)[matches count] - 1;
    for (int i = lastIndex; i >= 0; i--) {
        NSTextCheckingResult *match = matches[i];
        NSRange hRange = NSMakeRange([match range].location, 1);
        text = [text stringByReplacingCharactersInRange:hRange withString:@""];
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
                                                       STKPostURLKey : URLString,
                                                       STKPostVisibilityKey : STKPostVisibilityPublic
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
                                           STKPostURLKey : URLString,
                                           STKPostVisibilityKey : STKPostVisibilityPublic
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
/*
- (void)transferPostsFromTumblrWithLastMinimumID:(NSString *)minID
                              completion:(void (^)(NSString *lastID, NSError *err))block
{
    STKUser *u = [[STKUserStore store] currentUser];
    if ([u tumblrToken] && [u tumblrTokenSecret] && minID) {
        [[TMAPIClient sharedInstance] setOAuthToken:[u tumblrToken]];
        [[TMAPIClient sharedInstance] setOAuthTokenSecret:[u tumblrTokenSecret]];
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(minID, nil);
        }];
        return;
    }
    
    
    [[TMAPIClient sharedInstance] userInfo:^(NSDictionary* response, NSError *error) {
        if (!error) {
            NSArray *blogs = response[@"user"][@"blogs"];
            
            __block NSUInteger hostCount = [blogs count];
            __block NSMutableArray *posts = [NSMutableArray array];
            for (NSDictionary *blog in blogs) {
                NSURL *url = [NSURL URLWithString:blog[@"url"]];
                NSString *host = [url host];
                
                NSMutableArray *postsInBlog = [NSMutableArray array];
                [self fetchRecentTumblrPosts:host fetchedSoFar:postsInBlog lastMinimumID:minID completion:^(NSArray *p, NSError *err) {
                    if (!error) {
                        [posts addObjectsFromArray:p];
                        
                        hostCount--;
                        if (hostCount == 0) {
                            NSArray *sortedPosts = [posts sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
                            
                            [self createPostsForTumblr:sortedPosts];
                            NSString *newLastMin = minID;
                            if ([sortedPosts firstObject]) {
                                newLastMin = [sortedPosts firstObject][@"date"];
                            }
                            block(newLastMin, error);
                        }
                    } else {
                        block(minID, error);
                    }
                }];
            }
        } else {
            block(minID, error);
        }
    }];
}

- (void)fetchRecentTumblrPosts:(NSString *)host fetchedSoFar:(NSMutableArray *)fetchedSoFar lastMinimumID:(NSString *)minID completion:(void (^)(NSArray *posts, NSError *err))block
{
    NSMutableDictionary *parameters = [@{@"filter" : @"text"} mutableCopy];
    
    if ([fetchedSoFar count]) {
        parameters[@"offset"] = @([fetchedSoFar count]);
    }
    
    [[TMAPIClient sharedInstance] posts:host type:nil parameters:parameters callback:^(NSDictionary *response, NSError *error) {
        if (!error) {
            BOOL morePosts = YES;
            NSArray *posts = response[@"posts"];
            
            if ([posts count]) {
                if (minID) {
                    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                        NSString *date = [evaluatedObject objectForKey:@"date"];
                        
                        // want minID to be less than date
                        if ([minID compare:date] == NSOrderedAscending) {
                            return YES;
                        }

                        return NO;
                    }];
                    NSArray *filteredPosts = [posts filteredArrayUsingPredicate:predicate];
                    [fetchedSoFar addObjectsFromArray:filteredPosts];
                    
                    if ([posts count] > [filteredPosts count]) {
                        morePosts = NO;
                    }
                } else {
                    [fetchedSoFar addObjectsFromArray:posts];
                }
            } else {
                morePosts = NO;
            }
            
            if (morePosts == NO) {
                block(fetchedSoFar, error);
            } else {
                [self fetchRecentTumblrPosts:host fetchedSoFar:fetchedSoFar lastMinimumID:minID completion:block];
            }
        } else {
            block(nil, error);
        }
    }];
}

- (void)createPostsForTumblr:(NSArray *)posts
{
    NSDictionary *post = [posts lastObject];
    
    if (post == nil) {
        return;
    }
    BOOL createPost = NO;
    
    // catch tumblr official tagged
    NSArray *tumblrTags = post[@"tags"];
    if ([tumblrTags containsObject:@"prizm"]) {
        createPost = YES;
    }
    // links have url, title, description
    // quotes have text, source
    // text has title body
    // photos have caption
    
    NSString *title = post[@"title"];
    NSString *description = post[@"description"];
    NSString *body = post[@"body"];
    NSString *text = post[@"text"];
    NSString *caption = post[@"caption"];
    NSString *source = post[@"source"];
    
    // construct postText and imageURL
    NSString *postText = @"";
    NSString *imageURL;
    
    if ([post[@"type"] isEqualToString:@"text"]) {
        NSMutableString *s = [NSMutableString string];
        if (title) {
            [s appendFormat:@"%@\n", title];
        }
        if (body) {
            [s appendFormat:@"%@\n", body];
        }
        
        if ([s length]) {
            postText = [s substringToIndex:[s length] - 1];
        }
    }
    if ([post[@"type"] isEqualToString:@"link"]) {
        NSMutableString *s = [NSMutableString string];
        NSString *url = post[@"url"];
        if (title) {
            [s appendFormat:@"%@\n", title];
        }
        if (url) {
            [s appendFormat:@"%@\n", url];
        }
        if (description) {
            [s appendFormat:@"%@\n", description];
        }
        
        if ([s length]) {
            postText = [s substringToIndex:[s length] - 1];
        }
    }
    if ([post[@"type"] isEqualToString:@"quote"]) {
        NSMutableString *s = [NSMutableString string];
        if (text) {
            [s appendFormat:@"%@\n", text];
        }
        if (source) {
            [s appendFormat:@"%@\n", source];
        }
        
        if ([s length]) {
            postText = [s substringToIndex:[s length] - 1];
        }
    } else {
        if (caption) {
            postText = caption;
        }
        
        NSDictionary *photo = [post[@"photos"] firstObject];
        imageURL = photo[@"original_size"][@"url"];
    }
    
    // catch content with #prizm
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"#prizm" options:0 error:nil];
    NSTextCheckingResult *result = [exp firstMatchInString:postText options:0 range:NSMakeRange(0, [postText length])];
    
    if (result) {
        createPost = YES;
    }
    
    NSString *type = post[@"type"];
    
    // type and status get final say
    if ([type isEqualToString:@"video"] || [type isEqualToString:@"audio"] ||
        [type isEqualToString:@"chat"] || [type isEqualToString:@"answer"] ||
        [post[@"state"] isEqualToString:@"published"] == NO) {
        
        createPost = NO;
    }
    
    if (createPost) {
        NSString *postType = STKPostTypeExperience;
        NSString *lowercaseSearchString = [postText lowercaseString];
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
        
        NSString *link = post[@"post_url"];
        
        if (imageURL) {
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
            NSURLSessionDataTask *dt = [[[STKBaseStore store] session] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(!error) {
                    UIImage *img = [UIImage imageWithData:data];
                    if(img) {
                        [[STKImageStore store] uploadImage:img thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
                            if(!err) {
                                NSDictionary *postInfo = @{
                                                           STKPostTextKey : postText,
                                                           STKPostTypeKey : postType,
                                                           @"external_provider" : @"tumblr",
                                                           @"external_link" : link,
                                                           STKPostURLKey : URLString
                                                           };
                                
                                [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
                                    if(!err) {
                                        NSMutableArray *a = [posts mutableCopy];
                                        [a removeLastObject];
                                        [self createPostsForTumblr:a];
                                    }
                                }];
                            }
                            
                        }];
                    }
                }
            }];
            [dt resume];
        } else {
            UIImage *img = [STKMarkupUtilities imageForText:postText];
            [[STKImageStore store] uploadImage:img thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
                if(!err) {
                    NSDictionary *postInfo = @{
                                               STKPostTextKey : postText,
                                               STKPostTypeKey : postType,
                                               @"external_provider" : @"tumblr",
                                               @"external_link" : link,
                                               STKPostURLKey : URLString
                                               };
                    
                    [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
                        if(!err) {
                            NSMutableArray *a = [posts mutableCopy];
                            [a removeLastObject];
                            [self createPostsForTumblr:a];
                        }
                    }];
                }
            }];
        }
    } else {
        NSMutableArray *a = [posts mutableCopy];
        [a removeLastObject];
        [self createPostsForTumblr:a];
    }
}
*/
@end
