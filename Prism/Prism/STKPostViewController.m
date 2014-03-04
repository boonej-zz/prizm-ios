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

@interface STKPostViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIControl *overlayVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *commentFooterView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCommentConstraint;
- (void)dismissKeyboard:(id)sender;

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

- (IBAction)showLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKLocationViewController *lvc = [[STKLocationViewController alloc] init];
    [lvc setCoordinate:[[self post] coordinate]];
    [lvc setLocationName:[[self post] locationName]];
    [[self navigationController] pushViewController:lvc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];

    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, [[self commentFooterView] bounds].size.height, 0)];
    [[self tableView] setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [gr setCancelsTouchesInView:NO];
    [gr setDelaysTouchesBegan:NO];
    [gr setDelaysTouchesEnded:NO];
    [[self view] addGestureRecognizer:gr];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[self overlayVIew] setHidden:YES];
    [[self tableView] reloadData];
    
    [[STKContentStore store] fetchCommentsForPost:[self post]
                                       completion:^(STKPost *p, NSError *err) {
                                           [[self tableView] reloadData];
                                       }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO];
    [[self overlayVIew] setHidden:YES];

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

}

- (void)keyboardWillDisappear:(NSNotification *)note
{
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



- (void)imageTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)toggleLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([[self post] postLikedByCurrentUser]) {
        [[STKContentStore store] unlikePost:[self post]
                                 completion:^(STKPost *p, NSError *err) {
                                    [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                            withRowAnimation:UITableViewRowAnimationNone];
                                 }];
    } else {
        [[STKContentStore store] likePost:[self post]
                               completion:^(STKPost *p, NSError *err) {
                                   [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                           withRowAnimation:UITableViewRowAnimationNone];
                               }];
    }
    [[self tableView] reloadRowsAtIndexPaths:@[ip]
                            withRowAnimation:UITableViewRowAnimationNone];
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
    
}



- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    if([ip section] == 0) {
        STKProfileViewController *vc = [[STKProfileViewController alloc] init];
        [vc setProfile:[[self post] creator]];
        [[self navigationController] pushViewController:vc animated:YES];
    }
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
        return 421;
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
        return 421;
    }
    
    STKPostComment *pc = [self commentForIndexPath:indexPath];
    NSString *text = [pc text];
    if(!pc)
        text = [[self post] text];

    return [self heightForTableViewGivenCommentText:text];
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
        STKHomeCell *c = [STKHomeCell cellForTableView:tableView target:self];
        [[c topInset] setConstant:0];
        [[c leftInset] setConstant:0];
        [[c rightInset] setConstant:0];
        
        [c populateWithPost:[self post]];
        
        return c;
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
            [[c timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[comment date]]];

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

- (void)dismissKeyboard:(id)sender
{
 //   [[self view] endEditing:YES];

}

- (IBAction)postComment:(id)sender
{
    [[STKContentStore store] addComment:[[self commentTextField] text] toPost:[self post] completion:^(STKPost *p, NSError *err) {
        [[self tableView] reloadData];
    }];
    [[self commentTextField] setText:nil];
    [[self tableView] reloadData];
    [[self view] endEditing:YES];
    
    NSInteger index = [[[self post] comments] count] -1;
    if([self postHasText])
        index --;
    
    [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                inSection:1]
                            atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
@end
