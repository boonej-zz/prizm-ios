//
//  STKPostController.h
//  Prism
//
//  Created by Joe Conway on 3/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKPost;
@class STKPostController;
@class STKFetchDescription;

@protocol STKPostControllerDelegate <NSObject>

@optional

- (UIViewController *)viewControllerForPresentingPostInPostController:(STKPostController *)pc;

- (BOOL)postController:(STKPostController *)pc shouldContinueAfterTappingImageAtIndex:(int)idx;
- (BOOL)postController:(STKPostController *)pc shouldContinueAfterTappingCommentsAtIndex:(int)idx;
- (BOOL)postController:(STKPostController *)pc shouldContinueAfterTappingAvatarAtIndex:(int)idx;
- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx;

@end

@interface STKPostController : NSObject

- (id)initWithViewController:(UIViewController <STKPostControllerDelegate> *)viewController;

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSDictionary *filterMap;
@property (nonatomic, strong) void (^fetchMechanism)(STKFetchDescription *desc, void (^completion)(NSArray *posts, NSError *err));
@property (nonatomic, weak) id <STKPostControllerDelegate> delegate;

- (void)addPosts:(NSArray *)posts;

- (void)reloadWithCompletion:(void (^)(NSArray *newPosts, NSError *err))completion;
- (void)fetchNewerPostsWithCompletion:(void (^)(NSArray *newPosts, NSError *err))completion;
- (void)fetchOlderPostsWithCompletion:(void (^)(NSArray *newPosts, NSError *err))completion;

@end
