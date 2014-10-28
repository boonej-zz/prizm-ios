//
//  STKCreateCommentViewController.m
//  Prism
//
//  Created by Joe Conway on 7/15/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCreateCommentViewController.h"
#import "STKPost.h"
#import "STKPostComment.h"
#import "STKCommentCell.h"
#import "STKAvatarView.h"
#import "STKMarkupUtilities.h"
#import "STKMarkupController.h"
#import "STKUserStore.h"
#import "STKRelativeDateConverter.h"
#import "UIERealTimeBlurView.h"
#import "STKProcessingView.h"
#import "STKContentStore.h"
#import "STKProfileViewController.h"
#import "STKUserListViewController.h"
#import "STKWebViewController.h"
#import "STKHashtagPostsViewController.h"
#import "UIViewController+STKControllerItems.h"

@interface STKCreateCommentViewController ()
    <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STKMarkupControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (weak, nonatomic) IBOutlet UIView *commentContainer;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTableConstraint;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
//@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) STKMarkupController *markupController;


- (IBAction)postComment:(id)sender;

@end

@implementation STKCreateCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        [[self navigationItem] setTitle:@"Comments"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self postButton] setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.1]];
    [[self postButton] setClipsToBounds:YES];
    [[[self postButton] layer] setCornerRadius:10];

    [[self commentTableView] setBackgroundColor:[UIColor clearColor]];
    [[self commentTableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [[self commentTableView] setSeparatorColor:[UIColor colorWithWhite:0.5 alpha:0]];
    [[self commentTableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self commentTableView] setDelaysContentTouches:NO];
    [[self commentTableView] setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    _markupController = [[STKMarkupController alloc] initWithDelegate:self];
    [_markupController setHidesDoneButton:YES];
    [_markupController setAllowsAllUserTagging:YES];
    [[self view] addSubview:[[self markupController] view]];
    [self addBlurViewWithHeight:64.f];
    if([self editingPostText]) {
        [[self postButton] setTitle:@"Edit" forState:UIControlStateNormal];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self textView] becomeFirstResponder];

    if([self editingPostText] && [self postHasText]) {
        [[self textView] setAttributedText:[STKMarkupUtilities renderedTextForText:[[self post] text] attributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : STKTextColor}]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self resizeTextArea];
        }];
        [[self navigationItem] setTitle:@"Edit Post"];
    }
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (IBAction)postComment:(id)sender
{
    if([[[self textView] text] length] == 0) {
        return;
    }
    
    NSMutableAttributedString *text = [[[self textView] attributedText] mutableCopy];
    
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
        [STKProcessingView present];
        STKPost *p = [[[self post] managedObjectContext] obtainEditableCopy:[self post]];
        [p setText:actualText];
        [[STKContentStore store] editPost:p
                               completion:^(STKPost *result, NSError *err) {
                                   if (err) {
                                       [[STKErrorStore alertViewForError:err delegate:nil] show];
                                   } else {
                                       [[[self post] managedObjectContext] discardChangesToEditableObject:p];
                                       [STKProcessingView dismiss];
                                       [[self navigationController] popViewControllerAnimated:YES];
                                   }
                               }];
        
    } else {
        
        [[STKContentStore store] addComment:actualText toPost:[self post] completion:^(STKPost *p, NSError *err) {
            if (err) {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            } else {
                [self extractComments];
            }
        }];
        
        [[self textView] setText:nil];
        [self resizeTextArea];
        [self extractComments];
        
        long index = [[self comments] count] - 1;
        if([self postHasText]) {
            index ++;
        }
        NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
        [[self commentTableView] insertRowsAtIndexPaths:@[ip]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self commentTableView] scrollToRowAtIndexPath:ip
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
    }
}

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
                                        [[self commentTableView] reloadData];
                                    }];
        
    } else {
        [[STKContentStore store] likeComment:pc
                                  completion:^(STKPostComment *p, NSError *err) {
                                      if (err) {
                                          [[STKErrorStore alertViewForError:err delegate:nil] show];
                                      }
                                      [[self commentTableView] reloadData];
                                  }];
    }
    [[self commentTableView] reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
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


- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)setPost:(STKPost *)post
{
    _post = post;
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

- (void)keyboardWillAppear:(NSNotification *)note
{
    CGRect r = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [[self bottomContainerConstraint] setConstant:r.size.height];
    [[self bottomTableConstraint] setConstant:r.size.height + 82];
    [[self view] setNeedsUpdateConstraints];
    
    [[[self markupController] view] setFrame:CGRectMake(0, [[self view] bounds].size.height - r.size.height - [[self commentContainer] bounds].size.height - 45, 320, 44)];

    
    [[self commentTableView] setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKPostComment *pc = [self commentForIndexPath:indexPath];
    NSString *text = [pc text];
    if(!pc)
        text = [[self post] text];
    
    return [self heightForTableViewGivenCommentText:text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self editingPostText])
        return 1;
    
    NSInteger count = [[self comments] count];
    if([self postHasText])
        count ++;
    
    return count;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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


- (void)resizeTextArea
{
    // Resize if applicable
    CGRect wantedSize = [[[self textView] attributedText] boundingRectWithSize:CGSizeMake([[self textView] bounds].size.width - 16, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    float height = ceilf(wantedSize.size.height) + 20;
    if(height < 36)
        height = 36;
    if(height >= 100)
        height = 100;
    
    [[self heightContainerConstraint] setConstant:height];
    
    [[self view] setNeedsUpdateConstraints];
    
    CGRect currentMarkupFrame = [[[self markupController] view] frame];
    float delta = ([[self view] bounds].size.height - ([[self heightContainerConstraint] constant] + [[self bottomContainerConstraint] constant])) - currentMarkupFrame.size.height;
    currentMarkupFrame.origin.y = delta - 1;
    [[[self markupController] view] setFrame:currentMarkupFrame];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [[self markupController] textView:textView updatedWithText:[textView text]];
    [textView setFont:STKFont(14)];
    [textView setTintColor:STKTextColor];
    [self resizeTextArea];
}




- (void)markupController:(STKMarkupController *)markupController
           didSelectUser:(STKUser *)user
        forMarkerAtRange:(NSRange)range
{
    NSAttributedString *str = [STKMarkupUtilities userTagForUser:user attributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : STKTextColor}];
    
    if(range.location == NSNotFound) {
        range = NSMakeRange([[[self textView] textStorage] length], 0);
    }
    
    [[[self textView] textStorage] replaceCharactersInRange:range
                                              withAttributedString:str];
    [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                                                 attributes:@{NSFontAttributeName : STKFont(14),
                                                                                                              NSForegroundColorAttributeName: STKTextColor}]];
    
    NSInteger newIndex = range.location + [str length] + 2;
    [[self textView] setSelectedRange:NSMakeRange(newIndex, 0)];
    
}

- (void)markupController:(STKMarkupController *)markupController
        didSelectHashTag:(NSString *)hashTag
        forMarkerAtRange:(NSRange)range
{
    if(range.location == NSNotFound) {
        range = NSMakeRange([[[self textView] textStorage] length], 0);
    }
    
    [[[self textView] textStorage] replaceCharactersInRange:range
                                                        withString:[NSString stringWithFormat:@"#%@ ", hashTag]];
    [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                                                 attributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : STKTextColor}]];
    
    NSInteger newIndex = range.location + [hashTag length] + 2;
    [[self textView] setSelectedRange:NSMakeRange(newIndex, 0)];
}

- (void)markupControllerDidFinish:(STKMarkupController *)markupController
{
    //    [[self commentTextField] resignFirstResponder];
}
@end
