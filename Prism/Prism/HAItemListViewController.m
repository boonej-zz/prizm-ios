//
//  HAItemListViewController.m
//  Prizm
//
//  Created by Eric Kenny on 11/25/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAItemListViewController.h"
#import "STKTextFieldCell.h"
#import "UIViewController+STKControllerItems.h"
@interface HAItemListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HAItemListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self addBackgroundImage];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [self addBlurViewWithHeight:64.f];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self selectionBlock]) {
        [self selectionBlock]((int)[indexPath row]);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self items] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKTextFieldCell *c = [STKTextFieldCell cellForTableView:tableView target:self];
    [[c textField] setEnabled:NO];
    
    [[c label] setFont:STKFont(16)];
    [[c label] setTextColor:[UIColor whiteColor]];
    
    [[c label] setText:[[self items] objectAtIndex:[indexPath row]]];
    [c setSelectionStyle:UITableViewCellSelectionStyleGray];
    return c;
}

@end
