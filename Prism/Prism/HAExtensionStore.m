//
//  HAExtensionStore.m
//  Prizm
//
//  Created by Eric Kenny on 11/16/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAExtensionStore.h"
#import "STKPost.h"
#import "STKImageStore.h"
#import "STKUserStore.h"
#import "STKContentStore.h"


@implementation HAExtensionStore

- (void)createPostsFromExtensionDictionary:(NSDictionary *)post
{
    if ([post count] == 0) {
        return;
    }
    else {
        NSString *text = [post objectForKey:@"postText"];
        UIImage *img = [post objectForKey:@"postImage"];
        
        
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
        
        [[STKImageStore store] uploadImage:img thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
            if(!err) {
                NSDictionary *postInfo = @{
                                           STKPostTextKey : text,
                                           STKPostTypeKey : postType,
                                           @"external_provider" : @"shareExtension",
//                                           @"external_link" : link,
                                           STKPostURLKey : URLString,
                                           STKPostVisibilityKey : STKPostVisibilityPublic
                                           };
                
                [[STKContentStore store] addPostWithInfo:postInfo completion:^(STKPost *p, NSError *err) {
                    if(!err) {
                        NSLog(@"Extension works!");
                    }
                }];
            }
        }];
    }
}


@end
