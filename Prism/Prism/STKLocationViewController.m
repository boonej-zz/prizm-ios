//
//  STKLocationViewController.m
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLocationViewController.h"
@import MapKit;

@interface STKLocationViewController () <UITableViewDataSource, UITableViewDelegate>

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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (IBAction)openInMaps:(id)sender
{
    NSString *string = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@,%@",
                        [NSNumber numberWithDouble:[self coordinate].latitude],
                        [NSNumber numberWithDouble:[self coordinate].longitude]];
    
    NSURL *url = [NSURL URLWithString:string];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)toggleSingleView:(id)sender {
}

- (IBAction)toggleGridView:(id)sender {
}

@end
