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

@interface STKAccoladeViewController ()
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet STKLuminatingBar *luminatingBar;
@property (weak, nonatomic) IBOutlet STKSegmentedControl *typeControl;

@end

@implementation STKAccoladeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];
}

- (IBAction)typeChanged:(id)sender
{
    
}

@end
