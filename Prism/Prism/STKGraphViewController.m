//
//  STKGraphViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKGraphViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"

@interface STKGraphViewController ()

@end

@implementation STKGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_graph"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_graph_selected"]];
    }
    return self;
}
- (IBAction)tempLogout:(id)sender
{
    [[STKUserStore store] logout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
