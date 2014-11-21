//
//  STKTextInputViewController.m
//  Prism
//
//  Created by Joe Conway on 3/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTextInputViewController.h"

@interface STKTextInputViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation STKTextInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(save:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage HABackgroundImage]];
    [iv setFrame:[self.view bounds]];
    [self.view insertSubview:iv atIndex:0];
}

- (void)save:(id)sender
{
    [self setText:[[self textView] text]];
    if([self completion]) {
        [self completion]([self text]);
    }
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self textView] becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

    [[self textView] setText:[self text]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
