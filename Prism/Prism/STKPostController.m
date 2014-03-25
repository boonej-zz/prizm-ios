//
//  STKPostController.m
//  Prism
//
//  Created by Joe Conway on 3/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPostController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKCreatePostViewController.h"
#import "STKPost.h"
#import "STKLocationViewController.h"
#import "STKProfileViewController.h"
#import "STKContentStore.h"
#import "STKImageSharer.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKUserListViewController.h"
#import "STKImageStore.h"

@implementation STKPostController

// Should know how to filter deleted posts in some way!

- (id)initWithViewController:(UIViewController <STKPostControllerDelegate> *)viewController
{
    self = [super init];
    if(self) {
        _posts = [[NSMutableArray alloc] init];
        [self setDelegate:viewController];
        [self setViewController:viewController];
        [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
    }
    return self;
}

- (void)addPosts:(NSArray *)posts
{
    NSArray *dupes = [[self posts] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"postID in %@", [posts valueForKey:@"postID"]]];
    [[self posts] removeObjectsInArray:dupes];
    
    [[self posts] addObjectsFromArray:posts];
    
    if([[self sortDescriptors] count] > 0) {
        [[self posts] sortUsingDescriptors:[self sortDescriptors]];
    }
}


- (void)showPost:(STKPost *)p
{
    NSInteger idx = [[self posts] indexOfObject:p];
    
    UIImage *img = [[STKImageStore store] bestCachedImageForURLString:[p imageURLString]];
    
    if([[self delegate] respondsToSelector:@selector(postController:rectForPostAtIndex:)]) {
        CGRect r = [[self delegate] postController:self rectForPostAtIndex:idx];
        [[[self viewController] menuController] transitionToPost:p
                                                        fromRect:r
                                                      usingImage:img
                                                inViewController:[self viewController]
                                                        animated:YES];
    } else {
        [[[self viewController] menuController] transitionToPost:p
                                                        fromRect:CGRectZero
                                                      usingImage:img
                                                inViewController:[self viewController]
                                                        animated:NO];
    }
}

- (void)leftImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    int row = [ip row];
    int itemIndex = row * 3;
    if(itemIndex < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:itemIndex];
        [self showPost:p];
    }
}

- (void)centerImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    int row = [ip row];
    int itemIndex = row * 3 + 1;
    if(itemIndex < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:itemIndex];
        [self showPost:p];
    }
}

- (void)rightImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    int row = [ip row];
    int itemIndex = row * 3 + 2;
    if(itemIndex < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:itemIndex];
        [self showPost:p];
    }
}


- (void)showComments:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self delegate] respondsToSelector:@selector(postController:shouldContinueAfterTappingCommentsAtIndex:)]) {
        BOOL shouldContinue = [[self delegate] postController:self shouldContinueAfterTappingCommentsAtIndex:[ip row]];
        
        if(!shouldContinue)
            return;
    }

    STKPost *post = [[self posts] objectAtIndex:[ip row]];
    [self showPost:post];
}

- (void)imageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self delegate] respondsToSelector:@selector(postController:shouldContinueAfterTappingImageAtIndex:)]) {
        BOOL shouldContinue = [[self delegate] postController:self shouldContinueAfterTappingImageAtIndex:[ip row]];
        
        if(!shouldContinue)
            return;
    }
    STKPost *post = [[self posts] objectAtIndex:[ip row]];
    [self showPost:post];
}



- (void)addToPrism:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKCreatePostViewController *pvc = [[STKCreatePostViewController alloc] init];
    [pvc setOriginalPost:[[self posts] objectAtIndex:[ip row]]];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    
    [[self viewController] presentViewController:nvc animated:YES completion:nil];
}

- (void)sharePost:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [[self posts] objectAtIndex:[ip row]];
    UIActivityViewController *vc = [[STKImageSharer defaultSharer] activityViewControllerForPost:p
                                                                                   finishHandler:^(UIDocumentInteractionController *doc) {
                                                                                       [doc presentOpenInMenuFromRect:[[[self viewController] view] bounds]
                                                                                                               inView:[[self viewController] view]
                                                                                                             animated:YES];
                                                                                   }];
    if(vc) {
        [[self viewController] presentViewController:vc animated:YES completion:nil];
    }
}

- (void)showLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [[self posts] objectAtIndex:[ip row]];
    if([p locationName]) {
        STKLocationViewController *lvc = [[STKLocationViewController alloc] init];
        [lvc setCoordinate:[p coordinate]];
        [lvc setLocationName:[p locationName]];
        [[[self viewController] navigationController] pushViewController:lvc animated:YES];
    }
}

- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self delegate] respondsToSelector:@selector(postController:shouldContinueAfterTappingAvatarAtIndex:)]) {
        BOOL shouldContinue = [[self delegate] postController:self shouldContinueAfterTappingAvatarAtIndex:[ip row]];
        
        if(!shouldContinue)
            return;
    }

    STKPost *p = [[self posts] objectAtIndex:[ip row]];
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:[p creator]];
    [[[self viewController] navigationController] pushViewController:vc animated:YES];
}

- (void)toggleLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *post = [[self posts] objectAtIndex:[ip row]];
    if([[post creator] isEqual:[[STKUserStore store] currentUser]]) {
        STKUserListViewController *vc = [[STKUserListViewController alloc] init];
        [[STKContentStore store] fetchLikersForPost:[[self posts] objectAtIndex:[ip row]]
                                         completion:^(NSArray *likers, NSError *err) {
                                             [vc setUsers:likers];
                                         }];
        [[[self viewController] navigationController] pushViewController:vc animated:YES];
    } else {
        if([post postLikedByCurrentUser]) {
            [[STKContentStore store] unlikePost:post
                                     completion:^(STKPost *p, NSError *err) {/*
                                         [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                                 withRowAnimation:UITableViewRowAnimationNone];*/
                                     }];
        } else {
            [[STKContentStore store] likePost:post
                                   completion:^(STKPost *p, NSError *err) {
                                       /*[[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                               withRowAnimation:UITableViewRowAnimationNone];*/
                                   }];
        }
        /*
        [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                withRowAnimation:UITableViewRowAnimationNone];*/
        
    }
}

@end
