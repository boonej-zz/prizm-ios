//
//  STKTrustViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTrustViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTrustView.h"
#import "STKCountView.h"

@interface STKTrustViewController ()

@property (weak, nonatomic) IBOutlet STKTrustView *trustView;
@property (weak, nonatomic) IBOutlet STKCountView *countView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation STKTrustViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Trust"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_trust"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_trust_selected"]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self countView] setCircleTitles:@[@"Likes", @"Comments", @"Posts"]];
    [[self countView] setCircleValues:@[@"0", @"0", @"0"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
