//
//  STKAccountChooserViewController.m
//  Prism
//
//  Created by Joe Conway on 12/23/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKAccountChooserViewController.h"
#import "STKUserStore.h"
#import "STKProcessingView.h"
#import "STKCreateProfileViewController.h"
#import "STKErrorStore.h"
#import "STKLabelCell.h"

@import Accounts;

@interface STKAccountChooserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *accounts;
@end

@implementation STKAccountChooserViewController

- (id)initWithAccounts:(NSArray *)accounts
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _accounts = accounts;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithAccounts:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] registerNib:[UINib nibWithNibName:@"STKLabelCell" bundle:nil]
           forCellReuseIdentifier:@"STKLabelCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACAccount *acct = [[self accounts] objectAtIndex:[indexPath row]];
    [STKProcessingView present];
    [[STKUserStore store] connectWithTwitterAccount:acct completion:^(STKUser *existingUser, STKProfileInformation *registrationData, NSError *err) {
        [STKProcessingView dismiss];
        if(!err) {
            if(registrationData) {
                STKCreateProfileViewController *pvc = [[STKCreateProfileViewController alloc] init];
                [pvc setProfileInformation:registrationData];
                [[self navigationController] pushViewController:pvc animated:YES];
            } else if(existingUser) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self accounts] count];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKLabelCell *c = (STKLabelCell *)[tableView dequeueReusableCellWithIdentifier:@"STKLabelCell"];
    
    ACAccount *acct = [[self accounts] objectAtIndex:[indexPath row]];
    [[c label] setText:[NSString stringWithFormat:@"@%@", [acct username]]];
    [[c label] setTextColor:[UIColor whiteColor]];
    
    return c;
}

@end
