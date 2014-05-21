//
//  STKItemListViewController.m
//  Prism
//
//  Created by Joe Conway on 5/20/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKItemListViewController.h"
#import "STKTextFieldCell.h"

@interface STKItemListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STKItemListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self view] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self selectionBlock]) {
        [self selectionBlock]([indexPath row]);
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
