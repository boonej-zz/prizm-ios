//
//  STKPostViewController.m
//  Prism
//
//  Created by Joe Conway on 1/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPostViewController.h"
#import "STKPostCell.h"
#import "STKPost.h"
#import "STKProfileViewController.h"
#import "STKLocationViewController.h"
#import "STKContentStore.h"
#import "STKCommentCell.h"
#import "STKPostComment.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKRelativeDateConverter.h"
#import "STKCreatePostViewController.h"
#import "STKImageSharer.h"
#import "STKAvatarView.h"
#import "STKPostHeaderView.h"
#import "STKProcessingView.h"
#import "STKWebViewController.h"
#import "STKPostController.h"
#import "STKUserListViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKRenderServer.h"
#import "STKTextImageCell.h"
#import "STKHashtagPostsViewController.h"
#import "STKMarkupController.h"
#import "STKMarkupUtilities.h"
#import "UIERealTimeBlurView.h"

@interface STKPostViewController ()
    <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate,
    UITextViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate,
    STKPostControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,
    STKMarkupControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postButtonRightConstraint;
@property (weak, nonatomic) IBOutlet STKPostHeaderView *fakeHeaderView;
@property (weak, nonatomic) IBOutlet UIView *fakeContainerView;
@property (weak, nonatomic) IBOutlet UIControl *overlayVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *commentFooterView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *commentBarPlaceholder;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCommentConstraint;
@property (nonatomic, strong) UIView *commentHeaderView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *visibilityControl;
@property (weak, nonatomic) IBOutlet UIView *editOverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *editMenuBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *editPostButton;
@property (weak, nonatomic) IBOutlet UIView *editViewAnimationContainer;
@property (nonatomic, strong) NSArray *categoryItems;

@property (nonatomic, strong) STKMarkupController *markupController;

@property (weak, nonatomic) IBOutlet STKResolvingImageView *stretchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stretchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stretchWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editMenuContainerBottomConstraint;

@property (nonatomic, strong) STKPostCell *postCell;
@property (nonatomic) BOOL editingPostText;
@property (nonatomic) BOOL editMenuVisible;

@property (nonatomic, strong) STKPostController *postController;
@property (nonatomic, strong) NSMutableArray *comments;

@property (strong, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;


- (IBAction)postComment:(id)sender;
- (IBAction)changeVisibility:(id)sender;
- (BOOL)postHasText;
- (IBAction)editPost:(id)sender;

- (STKPostComment *)commentForIndexPath:(NSIndexPath *)ip;

@end

@implementation STKPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        [self setComments:[[NSMutableArray alloc] init]];
        _postController = [[STKPostController alloc] initWithViewController:self];
        _categoryItems = @[
                           @{@"title" : @"Aspiration", STKPostTypeKey : STKPostTypeAspiration, @"image" : [UIImage imageNamed:@"category_aspiration_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_aspirations_selected"]},
                           @{@"title" : @"Passion", STKPostTypeKey : STKPostTypePassion, @"image" : [UIImage imageNamed:@"category_passions_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_passions_selected"]},
                           @{@"title" : @"Experience", STKPostTypeKey : STKPostTypeExperience, @"image" : [UIImage imageNamed:@"category_experiences_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_experiences_selected"]},
                           @{@"title" : @"Achievement", STKPostTypeKey : STKPostTypeAchievement, @"image" : [UIImage imageNamed:@"category_achievements_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_achievements_selected"]},
                           @{@"title" : @"Inspiration", STKPostTypeKey : STKPostTypeInspiration, @"image" : [UIImage imageNamed:@"category_inspiration_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_inspiration_selected"]},
                           @{@"title" : @"Personal", STKPostTypeKey : STKPostTypePersonal, @"image" : [UIImage imageNamed:@"category_personal_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_personal_selected"]}
                           ];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_cancel"]
                                                  landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(dismiss:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
    }
    return self;
}

- (void)dismiss:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)setPost:(STKPost *)post
{
    _post = post;
    [[self postController] addPosts:@[post]];
    [self extractComments];
}

- (void)extractComments
{
    [self setComments:[[[[self post] comments] allObjects] mutableCopy]];
    [[self comments] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
}

- (BOOL)postHasText
{
    return [[[self post] text] length] > 0;
}

- (IBAction)editPost:(id)sender
{
    [[self view] endEditing:YES];
    [self setEditMenuVisible:YES];
}

- (void)setEditingPostText:(BOOL)editingPostText
{
    _editingPostText = editingPostText;
    if([self editingPostText]) {
        [[self postButton] setTitle:@"Edit" forState:UIControlStateNormal];
    } else {
        [[self postButton] setTitle:@"Post" forState:UIControlStateNormal];
    }

}

- (STKPostComment *)commentForIndexPath:(NSIndexPath *)ip
{
    NSInteger index = [ip row];
    
    if([self postHasText]) {
        index --;
    }

    if(index >= 0 && index < [[self comments] count]) {
        return [[self comments] objectAtIndex:index];
    }
    
    return nil;
}

- (void)setEditMenuVisible:(BOOL)editMenuVisible
{
    _editMenuVisible = editMenuVisible;
    
    if([self editMenuVisible]) {
        // There is a 'wrapper' view around the editView for purposes of animation
        //        CGRect r = [[self view] convertRect:[[[self editView] superview] frame]
        //                                   fromView:[self overlayVIew]];
        
        UIImage *img = [[STKRenderServer renderServer] instantBlurredImageForView:[self view]
                                                                        inSubrect:CGRectMake(0,
                                                                                             [[self view] bounds].size.height - [[self commentFooterView] bounds].size.height - [[self editView] bounds].size.height,
                                                                                             [[self editView] bounds].size.width,
                                                                                             [[self editView] bounds].size.height)];
        [[self editMenuBackgroundImageView] setImage:img];
        

        [[self editMenuContainerBottomConstraint] setConstant:0];
        [UIView animateWithDuration:0.2 animations:^{
            [[self editOverlayView] layoutIfNeeded];
            [[self editPostButton] setTransform:CGAffineTransformMakeRotation(M_PI)];
        }];
        
        [[self editOverlayView] setHidden:NO];
        int index = [[@{STKPostVisibilityPublic : @0, STKPostVisibilityTrust : @1, STKPostVisibilityPrivate : @2}
                      objectForKey:[[self post] visibility]] intValue];
        [[self visibilityControl] setSelectedSegmentIndex:index];
        
        

    } else {
        [[self editMenuContainerBottomConstraint] setConstant:-[[self editView] bounds].size.height];
        [UIView animateWithDuration:0.2 animations:^{
            [[self editOverlayView] layoutIfNeeded];
            [[self editPostButton] setTransform:CGAffineTransformIdentity];
        } completion:^(BOOL finished) {
            if(finished) {
                [[self editOverlayView] setHidden:YES];
            }
        }];

    }
    

}

- (IBAction)deleteMainPost:(id)sender
{
    [self setEditMenuVisible:NO];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                 message:@"Are you sure you want to delete this post?"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];

    [av show];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if([[URL scheme] isEqualToString:@"http"] || [[URL scheme] isEqualToString:@"https"]) {
        STKWebViewController *wvc = [[STKWebViewController alloc] init];
        [wvc setUrl:URL];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:wvc];
        [self presentViewController:nvc animated:YES completion:nil];
    } else if([[URL scheme] isEqualToString:STKPostHashTagURLScheme]) {
        STKHashtagPostsViewController *pvc = [[STKHashtagPostsViewController alloc] initWithHashTag:[URL host]];
        [[self navigationController] pushViewController:pvc animated:YES];
    } else if([[URL scheme] isEqualToString:STKPostUserURLScheme]) {
        [self showProfileForUser:[[STKUserStore store] userForID:[URL host]]];


    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        [STKProcessingView present];
        [[STKContentStore store] deletePost:[self post] completion:^(id obj, NSError *err) {
            [STKProcessingView dismiss];
            if(err) {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            } else {
                [[self navigationController] popViewControllerAnimated:YES];
            }
        }];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _markupController = [[STKMarkupController alloc] initWithDelegate:self];
    [_markupController setHidesDoneButton:YES];
    [[self overlayVIew] addSubview:[[self markupController] view]];
    
    [[self categoryCollectionView] registerNib:[UINib nibWithNibName:@"STKTextImageCell" bundle:nil]
                    forCellWithReuseIdentifier:@"STKTextImageCell"];
    [[self categoryCollectionView] setBackgroundColor:[UIColor clearColor]];
    [[self categoryCollectionView] setScrollEnabled:NO];

    
    [[self postButton] setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.1]];
    [[self postButton] setClipsToBounds:YES];
    [[[self postButton] layer] setCornerRadius:10];
    
    [[self editMenuContainerBottomConstraint] setConstant:-[[self editView] bounds].size.height];

    [[self editViewAnimationContainer] setClipsToBounds:YES];
    
    [[[self editPostButton] imageView] setContentMode:UIViewContentModeCenter];
    
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];

    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [[self tableView] setSeparatorColor:[UIColor colorWithWhite:0.5 alpha:0]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self tableView] setDelaysContentTouches:NO];
    [[self tableView] setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];


    [[self postButtonRightConstraint] setConstant:-[[self postButton] bounds].size.width - 3];
    
    [[[self fakeHeaderView] avatarButton] addTarget:self action:@selector(avatarTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    [[self tableView] setTableFooterView:footerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self blurView] displayLink] setPaused:NO];
    
    STKPostCell *c = [STKPostCell cellForTableView:[self tableView] target:[self postController]];
    [c setOverrideLoadingImage:[[self menuController] transitioningImage]];
    [[c contentImageView] setLoadingContentMode:[[c contentImageView] normalContentMode]];
    [c setDisplayFullBleed:YES];
    [[c contentImageView] setPreferredSize:STKImageStoreThumbnailNone];
    [c populateWithPost:[self post]];
    [self setPostCell:c];

    
    if([self isMovingToParentViewController])
        [[[self postCell] contentImageView] setHidden:YES];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[self overlayVIew] setHidden:YES];

    [[self stretchView] setUrlString:[[self post] imageURLString]];
    
    [[STKContentStore store] fetchCommentsForPost:[self post]
                                       completion:^(NSArray *comments, NSError *err) {
                                           [self setComments:[[[[self post] comments] allObjects] mutableCopy]];
                                           [[self comments] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
                                           [[self tableView] reloadData];
                                       }];
    [[STKContentStore store] fetchPost:[self post] completion:^(STKPost *p, NSError *err) {
        [self configureItems];
    }];
    
    [self configureItems];
}

- (void)configureItems
{
    [[self postCell] populateWithPost:[self post]];
    
    [[[self fakeHeaderView] avatarView] setUrlString:[[[self post] creator] profilePhotoPath]];
    [[[self fakeHeaderView] posterLabel] setText:[[[self post] creator] name]];
    [[[self fakeHeaderView] timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[[self post] datePosted]]];
    [[[self fakeHeaderView] postTypeView] setImage:[[self post] typeImage]];
    
    if([[self post] originalPost] && [[[[self post] originalPost] creator] name]){
        NSString * fromUser = [NSString stringWithFormat:@"Post via %@", [[[[self post] originalPost] creator] name]];
        [[[self fakeHeaderView] sourceLabel] setText:fromUser];
    } else if([[self post] externalProvider]){
        NSString *fromProvider = [NSString stringWithFormat:@"Post via %@", [[[self post] externalProvider] capitalizedString]];
        [[[self fakeHeaderView] sourceLabel] setText:fromProvider];
        
    } 

    [[self editPostButton] setHidden:[self shouldHideEditButton]];
    
    [[self tableView] reloadData];
}

- (BOOL)shouldHideEditButton
{
    if([[[[self post] creator] uniqueID] isEqualToString:[[[STKUserStore store] currentUser] uniqueID]]) {
        return NO;
    }
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[self postCell] contentImageView] setHidden:NO];
}

- (IBAction)overlayTapped:(id)sender
{
    [self setEditMenuVisible:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float visualOffsetY = [scrollView contentOffset].y + 40;
    
    if(visualOffsetY < 0) {
        [[self stretchView] setHidden:NO];
        float y = fabs(visualOffsetY);
        [[self stretchHeightConstraint] setConstant:300 + y];
        [[self stretchWidthConstraint] setConstant:320 + y];
    } else {
        [[self stretchView] setHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[[self blurView] displayLink] setPaused:YES];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [[self overlayVIew] setHidden:YES];
    if([self isMovingFromParentViewController]) {
        [[[self postCell] contentImageView] setHidden:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)commentOverlayTapped:(id)sender
{
    if([self editingPostText]) {
        [self setEditingPostText:NO];
    }
    [[self commentTextView] setText:nil];
    [[self view] endEditing:YES];
}

- (void)keyboardWillAppear:(NSNotification *)note
{
    [[self commentBarPlaceholder] setHidden:YES];
    
    CGRect r = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, r.size.height + [[self commentFooterView] bounds].size.height, 0)];

    float duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [[self bottomCommentConstraint] setConstant:r.size.height];
    [[self postButtonRightConstraint] setConstant:9];
    [[self view] setNeedsUpdateConstraints];
    
    
    [[self editPostButton] setHidden:YES];

    [[[self markupController] view] setHidden:YES];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [[self view] layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if(finished) {
                             [[[self markupController] view] setHidden:NO];

                             CGRect commentBoxRect = [[[self commentFooterView] superview] convertRect:[[self commentFooterView] frame] toView:[self view]];
                             CGRect converted = [[self view] convertRect:commentBoxRect toView:[self overlayVIew]];
                             [[[self markupController] view] setFrame:CGRectMake(0, converted.origin.y - 45, 320, 44)];
                         }
                     }];

    [[self overlayVIew] setHidden:NO];

    if([self editingPostText]) {
        [[self tableView] setContentOffset:CGPointMake(0, 216) animated:YES];
    } else {
        [[self tableView] scrollRectToVisible:CGRectMake(0, [[self tableView] contentSize].height - 1, 1, 1) animated:YES];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
    [[self commentBarPlaceholder] setHidden:NO];

    [[self editPostButton] setHidden:[self shouldHideEditButton]];
    
    [self setEditingPostText:NO];

    [[self tableView] setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];

    float duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [[self bottomCommentConstraint] setConstant:0];
    [[self postButtonRightConstraint] setConstant:-[[self postButton] bounds].size.width - 3];
    [[self view] setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [[self view] layoutIfNeeded];
                     } completion:nil];

    [[self overlayVIew] setHidden:YES];
}

- (IBAction)editPostText:(id)sender
{
    [self setEditMenuVisible:NO];
    
    [self setEditingPostText:YES];
    [[self commentTextView] setText:[[self post] text]];
    [[self commentTextView] becomeFirstResponder];
    [[self commentTextView] selectAll:nil];
}

- (UITableViewCell *)postController:(STKPostController *)pc cellForPostAtIndexPath:(NSIndexPath *)ip
{
    return [[self tableView] cellForRowAtIndexPath:ip];
}


- (BOOL)postController:(STKPostController *)pc shouldContinueAfterTappingImageAtIndex:(int)idx
{
    [[self navigationController] popViewControllerAnimated:YES];
    
    return NO;
}

- (BOOL)postController:(STKPostController *)pc shouldContinueAfterTappingCommentsAtIndex:(int)idx
{
    if([[self comments] count] > 0) {
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    return NO;
}

- (void)avatarTapped:(id)sender
{
    [self showProfileForUser:[[self post] creator]];
}


// This is for comments
- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPostComment *pc = [self commentForIndexPath:ip];
    STKUser *u = nil;
    if(pc) {
        u = [pc creator];
    } else {
        u = [[self post] creator];
    }
    
    [self showProfileForUser:u];
}

- (void)showProfileForUser:(STKUser *)u
{
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:u];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)toggleCommentLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPostComment *pc = [self commentForIndexPath:ip];
    if([pc isLikedByUser:[[STKUserStore store] currentUser]]) {
        [[STKContentStore store] unlikeComment:pc
                                    completion:^(STKPostComment *p, NSError *err) {
                                        if (err) {
                                            [[STKErrorStore alertViewForError:err delegate:nil] show];
                                        }
                                        [[self tableView] reloadData];
                                    }];

    } else {
        [[STKContentStore store] likeComment:pc
                                  completion:^(STKPostComment *p, NSError *err) {
                                      if (err) {
                                          [[STKErrorStore alertViewForError:err delegate:nil] show];
                                      }
                                      [[self tableView] reloadData];
                                  }];
    }
    [[self tableView] reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)showLikes:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUserListViewController *vc = [[STKUserListViewController alloc] init];
    STKPostComment *pc = [self commentForIndexPath:ip];
    if(pc) {
        [[STKContentStore store] fetchLikersForComment:pc completion:^(NSArray *likers, NSError *err) {
            [vc setUsers:likers];
        }];
        [[self navigationController] pushViewController:vc animated:YES];
    }

}


- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        STKPostComment *pc = [self commentForIndexPath:indexPath];
        [[STKContentStore store] deleteComment:pc completion:^(STKPost *p, NSError *err) {
            if (err) {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            } else {
                [self extractComments];
            }
            [[self tableView] reloadData];
        }];
        [self extractComments];
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self postCell] populateWithPost:[[[self postController] posts] firstObject]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 1) {
        STKPostComment *pc = [self commentForIndexPath:indexPath];
        if(pc) {
            if([[[self post] creator] isEqual:[[STKUserStore store] currentUser]]
            || [[pc creator] isEqual:[[STKUserStore store] currentUser]]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (CGFloat)heightForTableViewGivenCommentText:(NSString *)commentText
{
    static UIFont *f = nil;
    if(!f) {
        f = STKFont(14);
    }
    CGRect r = [commentText boundingRectWithSize:CGSizeMake(234, 10000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : f}
                                         context:nil];

    return (int)r.size.height + 65;
}
/*
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 433;
    }
    STKPostComment *pc = [self commentForIndexPath:indexPath];
    NSString *text = [pc text];
    if(!pc)
        text = [[self post] text];
    
    return [self heightForTableViewGivenCommentText:text];
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 433;
    }
    
    STKPostComment *pc = [self commentForIndexPath:indexPath];
    NSString *text = [pc text];
    if(!pc)
        text = [[self post] text];

    return [self heightForTableViewGivenCommentText:text];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
        return 21;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1) {
        if(![self commentHeaderView]) {
            _commentHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 21)];
            [_commentHeaderView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
            [[_commentHeaderView layer] setShadowColor:[[UIColor whiteColor] CGColor]];
            [[_commentHeaderView layer] setShadowOffset:CGSizeMake(0, -1)];
            [[_commentHeaderView layer] setShadowOpacity:0.35];
            [[_commentHeaderView layer] setShadowRadius:0];
            UIBezierPath *bp = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 320, 1)];
            [[_commentHeaderView layer] setShadowPath:[bp CGPath]];

            UILabel *lbl = [[UILabel alloc] initWithFrame:[_commentHeaderView bounds]];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setTextColor:STKTextColor];
            [lbl setFont:STKFont(13)];
            [lbl setText:@"Comments"];
            [_commentHeaderView addSubview:lbl];
        }
        
        return [self commentHeaderView];
    }
    
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    
    NSInteger count = [[self comments] count];
    if([self postHasText])
        count ++;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return [self postCell];
    } else {
        STKCommentCell *c = [STKCommentCell cellForTableView:tableView target:self];
        [[c textView] setDelegate:self];
        NSDictionary *attributes = @{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : STKTextColor};
        
        if([self postHasText] && [indexPath row] == 0) {
            
            [[c textView] setText:nil];
            
            NSAttributedString *str = [STKMarkupUtilities renderedTextForText:[[self post] text] attributes:attributes];
            [[c textView] setAttributedText:str];
            [[c nameLabel] setText:[[[self post] creator] name]];
            [[c avatarImageView] setUrlString:[[[self post] creator] profilePhotoPath]];
            
            [[c timeLabel] setHidden:YES];
            [[c clockImageView] setHidden:YES];
            [[c likeButton] setHidden:YES];
            [[c likeImageView] setHidden:YES];
            [[c likeCountLabel] setHidden:YES];
        } else {
            STKPostComment *comment = [self commentForIndexPath:indexPath];
            
            NSAttributedString *str = [STKMarkupUtilities renderedTextForText:[comment text] attributes:attributes];
            [[c textView] setAttributedText:str];
            [[c avatarImageView] setUrlString:[[comment creator] profilePhotoPath]];
            [[c nameLabel] setText:[[comment creator] name]];

            NSString *likeActionText = @"Like";
            if([comment isLikedByUser:[[STKUserStore store] currentUser]]) {
                likeActionText = @"Unlike";
            }
            [[c timeLabel] setText:[NSString stringWithFormat:@"%@ - %@", [STKRelativeDateConverter relativeDateStringFromDate:[comment date]], likeActionText]];

            [[c likeCountLabel] setText:[NSString stringWithFormat:@"%d", [comment likeCount]]];
            
            [[c timeLabel] setHidden:NO];
            [[c clockImageView] setHidden:NO];
            [[c likeButton] setHidden:NO];
            [[c likeImageView] setHidden:NO];
            [[c likeCountLabel] setHidden:NO];
        }
        
        return c;
    }
    
    return nil;
}

- (IBAction)postComment:(id)sender
{
    if([[[self commentTextView] text] length] == 0) {
        return;
    }
    
    NSMutableAttributedString *text = [[[self commentTextView] attributedText] mutableCopy];
    
    [text enumerateAttributesInRange:NSMakeRange(0, [text length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSTextAttachment *attachment = [attrs objectForKey:NSAttachmentAttributeName];
        if(attachment) {
            NSURL *userURL = [attrs objectForKey:NSLinkAttributeName];
            if(userURL) {
                NSString *uniqueID = [userURL host];
                [text replaceCharactersInRange:range withString:[NSString stringWithFormat:@"@%@", uniqueID]];
            }
        }
    }];
    NSString *actualText = [text string];
    
    if([self editingPostText]) {
        [self setEditingPostText:NO];
        
        [STKProcessingView present];
        STKPost *p = [[[self post] managedObjectContext] obtainEditableCopy:[self post]];
        [p setText:actualText];
        [[STKContentStore store] editPost:p
                               completion:^(STKPost *result, NSError *err) {
                                   if (err) {
                                       [[[self post] managedObjectContext] discardChangesToEditableObject:p];
                                       [STKProcessingView dismiss];
                                       [[self tableView] reloadData];
                                       [[STKErrorStore alertViewForError:err delegate:nil] show];
                                   }
                               }];
        
        [[self commentTextView] setText:nil];
        [[self view] endEditing:YES];
    } else {
        
        [[STKContentStore store] addComment:actualText toPost:[self post] completion:^(STKPost *p, NSError *err) {
            [self extractComments];
            if(err) {
                [[self postCell] populateWithPost:[self post]];
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }];
        
        [self extractComments];

        [[self postCell] populateWithPost:[self post]];
        [[self commentTextView] setText:nil];
        [[self view] endEditing:YES];

        int index = [[self comments] count] - 1;
        if([self postHasText]) {
            index ++;
        }
        NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:1];
        [[self tableView] insertRowsAtIndexPaths:@[ip]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self tableView] scrollToRowAtIndexPath:ip
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
    }
}

- (IBAction)changeVisibility:(UISegmentedControl *)sender
{
    NSDictionary *visibilityMap = @{@0 : STKPostVisibilityPublic, @1 : STKPostVisibilityTrust, @2: STKPostVisibilityPrivate};
    NSString *visibilityString = [visibilityMap
                                   objectForKey:@([sender selectedSegmentIndex])];

    STKPost *p = [[[self post] managedObjectContext] obtainEditableCopy:[self post]];
    NSString *revertVisibility = [p visibility];
    __block int revertIndex = NSNotFound;
    [visibilityMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:revertVisibility]) {
            revertIndex = [key integerValue];
        }
    }];

    void (^reversal)(void) = ^{
        [[self visibilityControl] setSelectedSegmentIndex:revertIndex];
    };
    
    if([visibilityString isEqualToString:STKPostVisibilityPrivate]) {
        [p setType:STKPostTypePersonal];
        [[self categoryCollectionView] reloadData];
    }
    
    [[STKContentStore store] editPost:p
                           completion:^(STKPost *result, NSError *err) {
                               [[[self post] managedObjectContext] discardChangesToEditableObject:p];
                               if (err) {
                                   [[STKErrorStore alertViewForError:err delegate:nil] show];
                                   reversal();
                               }
                               [[self tableView] reloadData];
                           }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self categoryItems] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[self categoryItems] objectAtIndex:[indexPath row]];
    STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                           forIndexPath:indexPath];
    [[cell label] setText:[item objectForKey:@"title"]];
    [[cell label] setTextColor:STKTextColor];
    [[cell imageView] setImage:[item objectForKey:@"image"]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if([[[self post] type] isEqualToString:[item objectForKey:STKPostTypeKey]]) {
        [[cell imageView] setImage:[item objectForKey:@"selectedImage"]];
        [[cell label] setTextColor:[UIColor whiteColor]];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *category = [[[self categoryItems] objectAtIndex:[indexPath row]] objectForKey:STKPostTypeKey];
    
    if ([[[self post] type] isEqualToString:category]) {
        return;
    }
    
    NSString *prevType = [[self post] type];
    NSString *prevVisibility = [[self post] visibility];
    
    NSDictionary *visibilityMap = @{@0 : STKPostVisibilityPublic, @1 : STKPostVisibilityTrust, @2: STKPostVisibilityPrivate};
    __block int revertIndex = NSNotFound;
    [visibilityMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:prevVisibility]) {
            revertIndex = [key integerValue];
        }
    }];
    
    void (^reversal)(void) = ^{
        [[self visibilityControl] setSelectedSegmentIndex:revertIndex];
        [[self post] setType:prevType];
        [[self post] setVisibility:prevVisibility];
    };
    
    [[self post] setType:category];
    
    if([[[self post] type] isEqualToString:STKPostTypePersonal]) {
        [[self post] setVisibility:STKPostVisibilityPrivate];
    } else {
        if([prevType isEqualToString:STKPostTypePersonal]) {
            [[self post] setVisibility:STKPostVisibilityTrust];
        }
    }
    if([[[self post] visibility] isEqualToString:STKPostVisibilityTrust])
        [[self visibilityControl] setSelectedSegmentIndex:1];
    else if([[[self post] visibility] isEqualToString:STKPostVisibilityPublic]) {
        [[self visibilityControl] setSelectedSegmentIndex:0];
    } else {
        [[self visibilityControl] setSelectedSegmentIndex:2];
    }
    
    [collectionView reloadData];
    
    [[STKContentStore store] editPost:[self post] completion:^(STKPost *p, NSError *err) {
        [[[self fakeHeaderView] postTypeView] setImage:[[self post] typeImage]];
        if (err) {
            reversal();
            [[STKErrorStore alertViewForError:err delegate:nil] show];
            [[self categoryCollectionView] reloadData];
        }
    }];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [[self markupController] textView:textView updatedWithText:[textView text]];
}

- (void)markupController:(STKMarkupController *)markupController
           didSelectUser:(STKUser *)user
        forMarkerAtRange:(NSRange)range
{
    NSAttributedString *str = [STKMarkupUtilities userTagForUser:user attributes:@{NSFontAttributeName : STKFont(16), NSForegroundColorAttributeName : STKTextColor}];
    
    if(range.location == NSNotFound) {
        range = NSMakeRange([[[self commentTextView] textStorage] length], 0);
    }
    
    [[[self commentTextView] textStorage] replaceCharactersInRange:range
                                           withAttributedString:str];
    [[[self commentTextView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                                              attributes:@{NSFontAttributeName : STKFont(16), NSForegroundColorAttributeName : STKTextColor}]];
    
    NSInteger newIndex = range.location + [str length] + 2;
    [[self commentTextView] setSelectedRange:NSMakeRange(newIndex, 0)];
    
}

- (void)markupController:(STKMarkupController *)markupController
        didSelectHashTag:(NSString *)hashTag
        forMarkerAtRange:(NSRange)range
{
    if(range.location == NSNotFound) {
        range = NSMakeRange([[[self commentTextView] textStorage] length], 0);
    }
    
    [[[self commentTextView] textStorage] replaceCharactersInRange:range
                                                     withString:[NSString stringWithFormat:@"#%@ ", hashTag]];
    [[[self commentTextView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                                              attributes:@{NSFontAttributeName : STKFont(16), NSForegroundColorAttributeName : STKTextColor}]];
    
    NSInteger newIndex = range.location + [hashTag length] + 2;
    [[self commentTextView] setSelectedRange:NSMakeRange(newIndex, 0)];
}

- (void)markupControllerDidFinish:(STKMarkupController *)markupController
{
//    [[self commentTextField] resignFirstResponder];
}



@end
