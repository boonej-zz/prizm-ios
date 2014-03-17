//
//  STKPostViewController.m
//  Prism
//
//  Created by Joe Conway on 1/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKPostViewController.h"
#import "STKHomeCell.h"
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

@interface STKPostViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet STKPostHeaderView *fakeHeaderView;
@property (weak, nonatomic) IBOutlet UIView *fakeContainerView;
@property (weak, nonatomic) IBOutlet UIControl *overlayVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *commentFooterView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCommentConstraint;
@property (nonatomic, strong) UIView *commentHeaderView;
@property (weak, nonatomic) IBOutlet UIButton *deletePostButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet STKResolvingImageView *stretchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stretchHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stretchWidthConstraint;

@property (nonatomic, strong) STKHomeCell *postCell;
@property (nonatomic) BOOL editingPostText;

- (IBAction)postComment:(id)sender;

- (BOOL)postHasText;

- (STKPostComment *)commentForIndexPath:(NSIndexPath *)ip;

@end

@implementation STKPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    return self;
}

- (BOOL)postHasText
{
    return [[[self post] text] length] > 0;
}

- (void)setEditingPostText:(BOOL)editingPostText
{
    _editingPostText = editingPostText;
    if([self editingPostText]) {
        [[self postButton] setTitle:@"Edit" forState:UIControlStateNormal];
        [[self deleteCommentButton] setHidden:YES];
    } else {
        [[self postButton] setTitle:@"Post" forState:UIControlStateNormal];
        [[self deleteCommentButton] setHidden:NO];
    }

}

- (STKPostComment *)commentForIndexPath:(NSIndexPath *)ip
{
    NSInteger index = [ip row];
    
    if([self postHasText]) {
        index --;
    }
    
    if(index >= 0 && index < [[[self post] comments] count])
        return [[[self post] comments] objectAtIndex:index];
    
    return nil;
}

- (IBAction)deleteMainPost:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                 message:@"Are you sure you want to delete this post?"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];

    [av show];
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

- (IBAction)showLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self post] locationName]) {
        STKLocationViewController *lvc = [[STKLocationViewController alloc] init];
        [lvc setCoordinate:[[self post] coordinate]];
        [lvc setLocationName:[[self post] locationName]];
        [[self navigationController] pushViewController:lvc animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];

    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [[self tableView] setSeparatorColor:[UIColor colorWithWhite:0.5 alpha:1]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, [[self commentFooterView] bounds].size.height, 0)];
    [[self tableView] setDelaysContentTouches:NO];

    [[self commentTextField] setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Write a comment..."
                                                                                      attributes:@{NSFontAttributeName : STKFont(12),
                                                                                                   NSForegroundColorAttributeName : [UIColor whiteColor]}]];
    [[[self commentFooterView] layer] setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [[[self commentFooterView] layer] setShadowOffset:CGSizeMake(0, -1)];
    [[[self commentFooterView] layer] setShadowOpacity:0.5];
    [[[self commentFooterView] layer] setShadowRadius:0];
 
    [[[self fakeHeaderView] avatarButton] addTarget:self action:@selector(avatarTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[self fakeHeaderView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UIView *internalFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, 320, 300)];
    [footerView addSubview:internalFooterView];
    [internalFooterView setBackgroundColor:[UIColor colorWithRed:190.0/255.0 green:195.0/255.0 blue:209.0/255.0 alpha:1]];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    [[self tableView] setTableFooterView:footerView];
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipe setDelegate:self];
    [[self view] addGestureRecognizer:swipe];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self deletePostButton] setHidden:![[[self post] creator] isEqual:[[STKUserStore store] currentUser]]];
    
    STKHomeCell *c = [STKHomeCell cellForTableView:[self tableView] target:self];
    [c setDisplayFullBleed:YES];
    [c populateWithPost:[self post]];
    [self setPostCell:c];
    
    [[[self postCell] contentImageView] setHidden:YES];
    
    [[self navigationController] setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[self overlayVIew] setHidden:YES];
    [[self tableView] reloadData];
    
    [[self stretchView] setUrlString:[[self post] imageURLString]];
    
    [[STKContentStore store] fetchCommentsForPost:[self post]
                                       completion:^(STKPost *p, NSError *err) {
                                           [[self tableView] reloadData];
                                       }];
    
    [[[self fakeHeaderView] avatarView] setUrlString:[[[self post] creator] profilePhotoPath]];
    [[[self fakeHeaderView] posterLabel] setText:[[[self post] creator] name]];
    [[[self fakeHeaderView] timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[[self post] datePosted]]];
    [[[self fakeHeaderView] postTypeView] setImage:[[self post] typeImage]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[self postCell] contentImageView] setHidden:NO];

}

- (void)swipeDown:(UIGestureRecognizer *)sender
{
//    if([sender state] == UIGestureRecognizerStateEnded) {
//        [[self view] endEditing:YES];
//    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([scrollView contentOffset].y < 0) {
        [[self stretchView] setHidden:NO];
        float y = fabs([scrollView contentOffset].y);
        [[self stretchHeightConstraint] setConstant:300 + y];
        [[self stretchWidthConstraint] setConstant:320 + y];
        
        if([scrollView contentOffset].y < -100) {
            if([self editingPostText]) {
                [self setEditingPostText:NO];
                [[self commentTextField] setText:nil];
            }
            [[self view] endEditing:YES];
        }
    } else {
        [[self stretchView] setHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[self navigationController] setNavigationBarHidden:NO];
    
    [[self overlayVIew] setHidden:YES];
    [[[self postCell] contentImageView] setHidden:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)keyboardWillAppear:(NSNotification *)note
{
    CGRect r = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, r.size.height + [[self commentFooterView] bounds].size.height, 0)];

    float duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [[self bottomCommentConstraint] setConstant:r.size.height];
    [UIView animateWithDuration:duration
                          delay:0
                        options:curve
                     animations:^{
                         [[self view] layoutIfNeeded];
                     } completion:nil];

    [[self overlayVIew] setHidden:NO];

    if([self editingPostText]) {
        [[self tableView] setContentOffset:CGPointMake(0, 216) animated:YES];
    } else {
        [[self tableView] scrollRectToVisible:CGRectMake(0, [[self tableView] contentSize].height - 1, 1, 1) animated:YES];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
    [self setEditingPostText:NO];

    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, [[self commentFooterView] bounds].size.height, 0)];

    float duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [[self bottomCommentConstraint] setConstant:0];
    [UIView animateWithDuration:duration
                          delay:0
                        options:curve
                     animations:^{
                         [[self view] layoutIfNeeded];
                     } completion:nil];

    [[self overlayVIew] setHidden:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 0 && ![self commentForIndexPath:indexPath] && [[[self post] creator] isEqual:[[STKUserStore store] currentUser]]) {
        [self setEditingPostText:YES];
        [[self commentTextField] setText:[[self post] text]];
        [[self commentTextField] becomeFirstResponder];
        [[self commentTextField] selectAll:nil];
    }
}

- (void)imageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)toggleLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self post] postLikedByCurrentUser]) {
        [[STKContentStore store] unlikePost:[self post]
                                 completion:^(STKPost *p, NSError *err) {
                                     [[self postCell] populateWithPost:[self post]];
                                 }];
    } else {
        [[STKContentStore store] likePost:[self post]
                               completion:^(STKPost *p, NSError *err) {
                                   [[self postCell] populateWithPost:[self post]];
                               }];
    }
    [[self postCell] populateWithPost:[self post]];
}

- (void)showComments:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[[self post] comments] count] > 0) {
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)addToPrism:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKCreatePostViewController *pvc = [[STKCreatePostViewController alloc] init];
    [pvc setImageURLString:[[self post] imageURLString]];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    
    [self presentViewController:nvc animated:YES completion:nil];

}

- (void)sharePost:(id)sender atIndexPath:(NSIndexPath *)ip
{
    UIActivityViewController *vc = [[STKImageSharer defaultSharer] activityViewControllerForImage:[[[self postCell] contentImageView] image]
                                                                                             text:[[self post] text]
                                                                                            post:[self post]
                                                                                    finishHandler:^(UIDocumentInteractionController *doc) {
                                                                                        [doc presentOpenInMenuFromRect:[[self view] bounds] inView:[self view] animated:YES];
                                                                                    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)avatarTapped:(id)sender
{
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:[[self post] creator]];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPostComment *pc = [self commentForIndexPath:ip];
    STKUser *u = nil;
    if(pc) {
        u = [pc user];
    } else {
        u = [[self post] creator];
    }
    
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:u];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)toggleCommentLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPostComment *pc = [self commentForIndexPath:ip];
    if([pc isLikedByCurrentUser]) {
        [[STKContentStore store] unlikeComment:pc
                                    completion:^(STKPostComment *p, NSError *err) {
                                        [[self tableView] reloadData];
                                    }];

    } else {
        [[STKContentStore store] likeComment:pc
                                  completion:^(STKPostComment *p, NSError *err) {
                                      [[self tableView] reloadData];
                                  }];
    }
    [[self tableView] reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        STKPostComment *pc = [self commentForIndexPath:indexPath];
        [[STKContentStore store] deleteComment:pc completion:^(STKPost *p, NSError *err) {
            [[self tableView] reloadData];
        }];
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self tableView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 1) {
        STKPostComment *pc = [self commentForIndexPath:indexPath];
        if(pc) {
            if([[[self post] creator] isEqual:[[STKUserStore store] currentUser]]
               || [[pc user] isEqual:[[STKUserStore store] currentUser]]) {
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
                                      attributes:@{NSFontAttributeName : f} context:nil];
    
    return r.size.height + 62;
}

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
}

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
    
    NSInteger count = [[[self post] comments] count];
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
        
        if([self postHasText] && [indexPath row] == 0) {
            [[c commentLabel] setText:[[self post] text]];
            [[c nameLabel] setText:[[[self post] creator] name]];
            [[c avatarImageView] setUrlString:[[[self post] creator] profilePhotoPath]];
            
            [[c timeLabel] setHidden:YES];
            [[c clockImageView] setHidden:YES];
            [[c likeButton] setHidden:YES];
            [[c likeImageView] setHidden:YES];
            [[c likeCountLabel] setHidden:YES];
        } else {
            STKPostComment *comment = [self commentForIndexPath:indexPath];
            
            [[c commentLabel] setText:[comment text]];
            [[c avatarImageView] setUrlString:[[comment user] profilePhotoPath]];
            [[c nameLabel] setText:[[comment user] name]];
            
            NSString *likeActionText = @"Like";
            if([comment isLikedByCurrentUser]) {
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
    if([[[self commentTextField] text] length] == 0) {
        return;
    }
    
    if([self editingPostText]) {
        [self setEditingPostText:NO];
        
        
        [[STKContentStore store] editPost:[self post]
                                 withInfo:@{@"text" : [[self commentTextField] text]}
                               completion:^(STKPost *p, NSError *err) {
                                   [[self tableView] reloadData];
                               }];
        
        [[self commentTextField] setText:nil];
        [[self view] endEditing:YES];
    } else {
        
        [[STKContentStore store] addComment:[[self commentTextField] text] toPost:[self post] completion:^(STKPost *p, NSError *err) {
            if(err) {
                [[self postCell] populateWithPost:[self post]];
            }
        }];
        [[self postCell] populateWithPost:[self post]];
        [[self commentTextField] setText:nil];
        [[self view] endEditing:YES];

        int index = [[[self post] comments] count] - 1;
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
@end
