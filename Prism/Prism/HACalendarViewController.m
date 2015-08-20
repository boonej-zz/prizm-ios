//
//  HACalendarViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 4/15/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HACalendarViewController.h"
#import "UIViewController+STKControllerItems.h"

@interface HACalendarViewController ()

@end

@implementation HACalendarViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self.tabBarItem setTitle:@"Calendar"];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_calendar"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_calendar_selected"]];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addBackgroundImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserUpdate) name:@"UserDetailsUpdated" object:nil];
    self.title = @"Calendar";
    UIBarButtonItem *bbi = [self menuBarButtonItem];
    [[self navigationItem] setLeftBarButtonItem:bbi];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menuWillAppear:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:[self switchGroupItem]];
}

- (void)menuWillDisappear:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
