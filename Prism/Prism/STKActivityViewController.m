//
//  STKActivityViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKActivityViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKActivityCell.h"
#import "STKUserStore.h"
#import "STKActivityItem.h"
#import "STKUserStore.h"
#import "STKRequestCell.h"
#import "STKRequestItem.h"
#import "STKProfile.h"
#import "STKRelativeDateConverter.h"
#import "UIERealTimeBlurView.h"

typedef enum {
    STKActivityViewControllerTypeActivity,
    STKActivityViewControllerTypeRequest
} STKActivityViewControllerType;

@interface STKActivityViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSArray *requests;
@property (nonatomic, strong) NSArray *activities;

@property (nonatomic) STKActivityViewControllerType currentType;
- (IBAction)typeChanged:(id)sender;

@end

@implementation STKActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Activity"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_notification"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_notification_selected"]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
    [[self tableView] setSeparatorColor:[UIColor colorWithWhite:1 alpha:0.5]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:YES];

}

- (void)setCurrentType:(STKActivityViewControllerType)currentType
{
    _currentType = currentType;
    [self refresh];
}

- (void)refresh
{
    if([self currentType] == STKActivityViewControllerTypeActivity) {
        
    } else if([self currentType] == STKActivityViewControllerTypeRequest) {
        [[STKUserStore store] fetchRequestsForCurrentUser:^(NSArray *requests, NSError *err) {
            if(!err)
                _requests = requests;
            
            [[self tableView] reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self currentType] == STKActivityViewControllerTypeRequest)
        return [[self requests] count];
    
    if([self currentType] == STKActivityViewControllerTypeActivity)
        return [[self activities] count];
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self currentType] == STKActivityViewControllerTypeActivity) {
        STKActivityCell *cell = [STKActivityCell cellForTableView:tableView target:self];
        STKActivityItem *i = [[self requests] objectAtIndex:[indexPath row]];
        
        [[cell profileImageView] setUrlString:[i profileImageURLString]];
        [[cell recentIndicatorImageView] setHidden:![i recent]];
        [[cell nameLabel] setText:[i userName]];
        [[cell activityTypeLabel] setText:[STKActivityItem stringForActivityItemType:[i type]]];
        [[cell imageReferenceView] setUrlString:[i referenceImageURLString]];
    } else if ([self currentType] == STKActivityViewControllerTypeRequest) {
        STKRequestCell *cell = [STKRequestCell cellForTableView:tableView target:self];
        STKRequestItem *i = [[self requests] objectAtIndex:[indexPath row]];
        
        [[cell avatarImageView] setUrlString:[[i requestingProfile] profilePhotoPath]];
        [[cell dateLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[i dateCreated]]];
        [[cell nameLabel] setText:[[i requestingProfile] name]];

        NSString *typeString = @"";
        if([[i type] isEqualToString:STKRequestTypeTrust])
            typeString = @"requested to join your trust.";
        else if([[i type] isEqualToString:STKRequestTypeAccolade])
            typeString = @"gave you an accolade!";
        
        [[cell typeLabel] setText:typeString];
        return cell;
    }
    
    return nil;
}

- (IBAction)typeChanged:(id)sender
{
    [self setCurrentType:[sender selectedSegmentIndex]];
}

@end
