//
//  HAShareExtensionHelper.m
//  Prizm
//
//  Created by Eric Kenny on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAShareExtensionHelper.h"
#import "STKPost.h"
#import "STKImageStore.h"
#import "STKMarkupUtilities.h"
#import "STKUserStore.h"
#import "STKContentStore.h"
#import "STKImageSharer.h"


NSString * const HATEXTKEY = @"postText";
NSString * const HAIMAGEKEY = @"postImage";
NSString * const HAAPPGROUP = @"group.com.higheraltitude.prism";


@interface HAShareExtensionHelper ()

@property (nonatomic) BOOL hasPost;
@property (nonatomic, strong) NSUserDefaults *postDefaults;

@end

@implementation HAShareExtensionHelper

+ (HAShareExtensionHelper *)helper
{
    static HAShareExtensionHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[HAShareExtensionHelper alloc] init];
    });
    return helper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setHasPost:FALSE];
    }
    return self;
}

- (void)checkForUserDefaults
{
    self.postDefaults = [[NSUserDefaults alloc] initWithSuiteName:HAAPPGROUP];
    [self setHasPost:[self hasPostFromExtension]];
    NSData *imageData = [self.postDefaults objectForKey:HAIMAGEKEY];
    UIImage* image = [UIImage imageWithData:imageData];
//    NSLog(@"postText: %@", [self.postDefaults objectForKey:HATEXTKEY]);
//    NSLog(@"postImage: %@", image);
}

- (BOOL)hasPostFromExtension
{
    BOOL hasPost = NO;
    if (([self.postDefaults objectForKey:HAIMAGEKEY] == nil) && ([self.postDefaults objectForKey:HATEXTKEY] == nil)) {
        hasPost = NO;
//        NSLog(@"Empty Post");
    }
    else {
        hasPost = YES;
//        NSLog(@"Post has image or text");
    }
    return hasPost;
}

- (void)clearPostInfoFromDefaults
{
    [self.postDefaults setObject:nil forKey:HATEXTKEY];
    [self.postDefaults setObject:nil forKey:HAIMAGEKEY];
//    NSLog(@"Post text should be nil: %@", [self.postDefaults objectForKey:HATEXTKEY]);
//    NSLog(@"Post image should be nil: %@", [self.postDefaults objectForKey:HAIMAGEKEY]);
}

- (void)createPostsFromDefaults
{
    if (!self.hasPost) {
        return;
    }
    
    NSString *text = [self.postDefaults objectForKey:HATEXTKEY];
//    NSString *userID = [[post objectForKey:@"user"] objectForKey:@"id"];
//    NSString *tweetID = [post objectForKey:@"id"];
//    NSString *link = [NSString stringWithFormat:@"http://twitter.com/%@/status/%@", userID, tweetID];
    
    NSString *postType = STKPostTypePersonal;
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
    
    UIImage *image;
    if ([self.postDefaults objectForKey:HAIMAGEKEY] == nil) {
        image = [STKMarkupUtilities imageForText:text];
    }
    else {
        NSData *imageData = [self.postDefaults objectForKey:HAIMAGEKEY];
        image = [UIImage imageWithData:imageData];
    }


    [[STKImageStore store] uploadImage:image thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
        if(!err) {
            NSDictionary *postInfo = @{
                                       STKPostTextKey : text,
                                       STKPostTypeKey : postType,
//                                       @"external_provider" : @"extension",
//                                       @"external_link" : link,
                                       STKPostURLKey : URLString,
                                       STKPostVisibilityKey : STKPostVisibilityPublic
                                       };
            
            [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
                if(!err) {
                    [self clearPostInfoFromDefaults];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViews" object:nil];
                }
            }];
        }
        
    }];
}


@end
