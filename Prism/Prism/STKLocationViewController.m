//
//  STKLocationViewController.m
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLocationViewController.h"
#import "STKContentStore.h"
#import "STKPostCell.h"
#import "STKTriImageCell.h"
#import "STKPostViewController.h"
#import "STKCreatePostViewController.h"
#import "STKProfileViewController.h"
#import "STKImageSharer.h"
#import "STKPostController.h"

@import MapKit;

@interface STKLocationViewController () <UITableViewDataSource, UITableViewDelegate, STKPostControllerDelegate>

@property (nonatomic, strong) STKPostController *localPosts;

@property (nonatomic) BOOL showPostsInSingleLayout;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)openInMaps:(id)sender;
- (IBAction)toggleSingleView:(id)sender;
- (IBAction)toggleGridView:(id)sender;

@end

@implementation STKLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _localPosts = [[STKPostController alloc] initWithViewController:self];
        [_localPosts setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [[self navigationItem] setLeftBarButtonItem:bbi];

    [self setTitle:[self locationName]];
    MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
    [placemark setCoordinate:[self coordinate]];
    [[self mapView] addAnnotation:placemark];
    
    [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance([self coordinate], 50, 50)];
    
    [[STKContentStore store] fetchPostsForLocationName:[self locationName]
                                             direction:STKContentStoreFetchDirectionNewer
                                         referencePost:[[[self localPosts] posts] firstObject]
                                            completion:^(NSArray *posts, NSError *err) {
                                                if(!err) {
                                                    [[self localPosts] addPosts:posts];
                                                }
                                                [[self tableView] reloadData];
                                            }];
}


- (IBAction)openInMaps:(id)sender
{
    NSString *string = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@,%@",
                        [NSNumber numberWithDouble:[self coordinate].latitude],
                        [NSNumber numberWithDouble:[self coordinate].longitude]];
    
    NSURL *url = [NSURL URLWithString:string];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)toggleSingleView:(id)sender
{
    [self setShowPostsInSingleLayout:YES];
    [[self tableView] reloadData];
}

- (IBAction)toggleGridView:(id)sender
{
    [self setShowPostsInSingleLayout:NO];
    
    [[self tableView] reloadData];
}

- (CGRect)postController:(STKPostController *)pc rectForPostAtIndex:(int)idx
{
    if([self showPostsInSingleLayout]) {
        STKPostCell *c = (STKPostCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        
        return [[self view] convertRect:[[c contentImageView] frame]
                               fromView:[[c contentImageView] superview]];

    } else {
        int row = idx / 3;
        int offset = idx % 3;
        
        STKTriImageCell *c = (STKTriImageCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        
        CGRect r = CGRectZero;
        if(offset == 0)
            r = [[c leftImageView] frame];
        else if(offset == 1)
            r = [[c centerImageView] frame];
        else if(offset == 2)
            r = [[c rightImageView] frame];
        
        return [[self view] convertRect:r fromView:c];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self showPostsInSingleLayout]) {
        STKPostCell *c = [STKPostCell cellForTableView:tableView target:[self localPosts]];
        
        [c populateWithPost:[[[self localPosts] posts] objectAtIndex:[indexPath row]]];
        
        return c;
    } else {
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:[self localPosts]];
        [c populateWithPosts:[[self localPosts] posts] indexOffset:[indexPath row]];
        
        return c;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self showPostsInSingleLayout]) {
        return 401;
    }
    return 106;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self showPostsInSingleLayout]) {
        return 401;
    }
    return 106;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self showPostsInSingleLayout]) {
        return [[[self localPosts] posts] count];
    } else {
        if([[[self localPosts] posts] count] % 3 > 0)
            return [[[self localPosts] posts] count] / 3 + 1;
        return [[[self localPosts] posts] count] / 3;
    }
}

@end
