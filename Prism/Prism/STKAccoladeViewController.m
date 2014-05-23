//
//  STKAccoladeViewController.m
//  Prism
//
//  Created by Joe Conway on 5/23/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKAccoladeViewController.h"
#import "UIERealTimeBlurView.h"
#import "STKLuminatingBar.h"
#import "STKSegmentedControl.h"
#import "STKActivityCell.h"
#import "STKCreateAccoladeViewController.h"
#import "STKUserStore.h"
#import "STKUser.h"

typedef enum {
    STKAccoladeTypeReceived,
    STKAccoladeTypeSent
} STKAccoladeType;

@interface STKAccoladeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet STKLuminatingBar *luminatingBar;
@property (weak, nonatomic) IBOutlet STKSegmentedControl *typeControl;

@property (nonatomic, strong) NSArray *accoladesReceived;
@property (nonatomic, strong) NSArray *accoladesSent;

@property (nonatomic) STKAccoladeType type;

@end

@implementation STKAccoladeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setTitle:@"Accolades"];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"post_accolades"] style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(postAccolade:)];
        [bbi setBackgroundVerticalPositionAdjustment:1 forBarMetrics:UIBarMetricsDefault];
        [[self navigationItem] setRightBarButtonItem:bbi];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setRowHeight:56];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setTableFooterView:v];
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(64 + 50, 0, 0, 0)];
}

- (void)postAccolade:(id)sender
{
    STKCreateAccoladeViewController *avc = [[STKCreateAccoladeViewController alloc] init];
    [avc setUser:[self user]];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)reloadAccolades
{
    [[self tableView] reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([[[self user] uniqueID] isEqualToString:[[[STKUserStore store] currentUser] uniqueID]]) {
        [[self navigationItem] setRightBarButtonItem:nil];
    }
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

    [[[self blurView] displayLink] setPaused:NO];
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

- (IBAction)typeChanged:(id)sender
{
    if([sender selectedSegmentIndex] == 0) {
        [self setType:STKAccoladeTypeReceived];
    } else if([sender selectedSegmentIndex]) {
        [self setType:STKAccoladeTypeSent];
    }
    
    [self reloadAccolades];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self type] == STKAccoladeTypeSent)
        return [[self accoladesSent] count];
    
    return [[self accoladesReceived] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKActivityCell *c = [STKActivityCell cellForTableView:tableView target:self];
    
    
    return c;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < 0) {
        float t = fabs(offset) / 60.0;
        if(t > 1)
            t = 1;
        [[self luminatingBar] setProgress:t];
    } else {
        [[self luminatingBar] setProgress:0];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(velocity.y > 0 && [scrollView contentSize].height - [scrollView frame].size.height - 20 < targetContentOffset->y) {
//        [self fetchOlderItems];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < -60) {
//        [self fetchNewItems];
    }
}


@end
