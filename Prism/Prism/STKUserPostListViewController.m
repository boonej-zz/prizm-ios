//
//  STKUserPostListViewController.m
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKUserPostListViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTriImageCell.h"
#import "STKResolvingImageView.h"
#import "STKPost.h"
#import "UIERealTimeBlurView.h"
#import "STKPostController.h"

@interface STKUserPostListViewController () <UITableViewDelegate, UITableViewDataSource, STKPostControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *filterBar;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIButton *personalButton;
@property (nonatomic, strong) STKPostController *postController;
@end

@implementation STKUserPostListViewController
@dynamic posts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        _postController = [[STKPostController alloc] initWithViewController:self];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
    }
    return self;
}
- (IBAction)togglePassions:(UIButton *)sender {
    
    [sender setSelected:![sender isSelected]];
}
- (IBAction)toggleAspirations:(UIButton *)sender {
    [sender setSelected:![sender isSelected]];
}
- (IBAction)toggleExperiences:(UIButton *)sender {
    [sender setSelected:![sender isSelected]];
}
- (IBAction)toggleAchievements:(UIButton *)sender {
    [sender setSelected:![sender isSelected]];
}
- (IBAction)toggleInspirations:(UIButton *)sender {
    [sender setSelected:![sender isSelected]];
}
- (IBAction)togglePersonal:(UIButton *)sender {
    [sender setSelected:![sender isSelected]];
}

- (void)setPosts:(NSArray *)posts
{
    [[self postController] addPosts:posts];
    [[self tableView] reloadData];
}

- (NSArray *)posts
{
    return [[self postController] posts];
}

- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx
{
    int row = idx / 3;
    int offset = idx % 3;
    
    STKTriImageCell *c = (STKTriImageCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
    CGRect r = CGRectZero;
    if(offset == 0)
        r = [[c leftImageView] frame];
    else if(offset == 1)
        r = [[c centerImageView] frame];
    else if(offset == 2)
        r = [[c rightImageView] frame];
    
    return [[self view] convertRect:r fromView:c];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self personalButton] setHidden:![self allowPersonalFilter]];

    
    [[self tableView] setRowHeight:106];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    [[self tableView] setContentInset:UIEdgeInsetsMake([[self filterBar] bounds].size.height + [[self filterBar] frame].origin.y, 0, 0, 0)];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];

}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[[self postController] posts] count] % 3 > 0)
        return [[[self postController] posts] count] / 3 + 1;
    return [[[self postController] posts] count] / 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self postController]];
    [c populateWithPosts:[[self postController] posts] indexOffset:[indexPath row] * 3];
    
    return c;
}

@end