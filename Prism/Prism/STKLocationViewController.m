//
//  STKLocationViewController.m
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLocationViewController.h"
#import "STKContentStore.h"
#import "STKHomeCell.h"
#import "STKTriImageCell.h"
#import "STKPostViewController.h"
#import "STKCreatePostViewController.h"
#import "STKProfileViewController.h"
#import "STKImageSharer.h"

@import MapKit;

@interface STKLocationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *posts;
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
        _posts = [[NSMutableArray alloc] init];
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
                                         referencePost:[[self posts] firstObject]
                                            completion:^(NSArray *posts, NSError *err) {
                                                if(!err) {
                                                    [[self posts] addObjectsFromArray:posts];
                                                    [[self posts] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datePosted" ascending:NO]]];
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

- (void)avatarTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *p = [[self posts] objectAtIndex:[ip row]];
    STKProfileViewController *vc = [[STKProfileViewController alloc] init];
    [vc setProfile:[p creator]];
    [[self navigationController] pushViewController:vc animated:YES];

}

- (void)toggleLike:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKPost *post = [[self posts] objectAtIndex:[ip row]];
    if([post postLikedByCurrentUser]) {
        [[STKContentStore store] unlikePost:post
                                 completion:^(STKPost *p, NSError *err) {
                                     [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                             withRowAnimation:UITableViewRowAnimationNone];
                                 }];
    } else {
        [[STKContentStore store] likePost:post
                               completion:^(STKPost *p, NSError *err) {
                                   [[self tableView] reloadRowsAtIndexPaths:@[ip]
                                                           withRowAnimation:UITableViewRowAnimationNone];
                               }];
    }
    [[self tableView] reloadRowsAtIndexPaths:@[ip]
                            withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)showComments:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [self showPostAtIndex:(int)[ip row]];
}


- (void)addToPrism:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKCreatePostViewController *pvc = [[STKCreatePostViewController alloc] init];
    [pvc setImageURLString:[[[self posts] objectAtIndex:[ip row]] imageURLString]];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
}

- (void)sharePost:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKHomeCell *c = (STKHomeCell *)[[self tableView] cellForRowAtIndexPath:ip];
    STKPost *post = [[self posts] objectAtIndex:[ip row]];
    UIActivityViewController *vc = [[STKImageSharer defaultSharer] activityViewControllerForImage:[[c contentImageView] image]
                                                                                             text:[post text]
                                                                                    finishHandler:^(UIDocumentInteractionController *doc) {
                                                                                        [doc presentPreviewAnimated:YES];
                                                                                    }];
    [self presentViewController:vc animated:YES completion:nil];
   
}

- (void)showLocation:(id)sender atIndexPath:(NSIndexPath *)ip
{
    // DO nothing!
}

- (void)showPostAtIndex:(int)idx
{
    if(idx < [[self posts] count]) {
        STKPostViewController *vc = [[STKPostViewController alloc] init];
        [vc setPost:[[self posts] objectAtIndex:idx]];
        [[self navigationController] pushViewController:vc animated:YES];
    }
}
- (void)leftImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSInteger row = [ip row];
    int itemIndex = (int)row * 3;
    [self showPostAtIndex:itemIndex];
}

- (void)centerImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSInteger row = [ip row];
    int itemIndex = (int)row * 3 + 1;
    [self showPostAtIndex:itemIndex];
    
}

- (void)rightImageButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSInteger row = [ip row];
    int itemIndex = (int)row * 3 + 2;
    [self showPostAtIndex:itemIndex];
}


- (void)populateTriImageCell:(STKTriImageCell *)c forRow:(int)row
{
    int arrayIndex = row * 3;
    
    if(arrayIndex + 0 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 0];
        [[c leftImageView] setUrlString:[p imageURLString]];
    } else {
        [[c leftImageView] setUrlString:nil];
    }
    if(arrayIndex + 1 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 1];
        [[c centerImageView] setUrlString:[p imageURLString]];
    } else {
        [[c centerImageView] setUrlString:nil];
    }
    
    if(arrayIndex + 2 < [[self posts] count]) {
        STKPost *p = [[self posts] objectAtIndex:arrayIndex + 2];
        [[c rightImageView] setUrlString:[p imageURLString]];
    } else {
        [[c rightImageView] setUrlString:nil];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self showPostsInSingleLayout]) {
        STKHomeCell *c = [STKHomeCell cellForTableView:tableView target:self];
        
        [c populateWithPost:[[self posts] objectAtIndex:[indexPath row]]];
        
        return c;
    } else {
        STKTriImageCell *c = [STKTriImageCell cellForTableView:tableView target:self];
        [self populateTriImageCell:c forRow:[indexPath row]];
        
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
        return [[self posts] count];
    } else {
        if([[self posts] count] % 3 > 0)
            return [[self posts] count] / 3 + 1;
        return [[self posts] count] / 3;
    }
}


@end
