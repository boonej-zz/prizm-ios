//
//  STKLocationListViewController.m
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLocationListViewController.h"
#import "STKFoursquareLocation.h"
#import "STKContentStore.h"
@import CoreLocation;

@interface STKLocationListViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation STKLocationListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager setDelegate:self];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
        
        
    }
    return self;
}

- (void)cancel:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] registerClass:[UITableViewCell class]
             forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self locationManager] startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *l = [locations lastObject];
    if([[l timestamp] timeIntervalSinceNow] > -60 * 3) {
        [[self locationManager] stopUpdatingLocation];
        
        //[[self postInfo] setObject:@([l coordinate].latitude) forKey:STKPostLocationLatitudeKey];
        //[[self postInfo] setObject:@([l coordinate].longitude) forKey:STKPostLocationLongitudeKey];
        [[STKContentStore store] fetchLocationNamesForCoordinate:[l coordinate] completion:^(NSArray *locations, NSError *err) {
            if(!err) {
                [self setLocations:locations];
                [[self tableView] reloadData];
            } else {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Finding Location"
                                                             message:[err localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self delegate] locationListViewController:self
                                  choseLocation:[[self locations] objectAtIndex:[indexPath row]]];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Finding Location"
                                                 message:[error localizedDescription]
                                                delegate:nil
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [manager stopUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self locationManager] stopUpdatingLocation];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self locations] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    [[cell textLabel] setText:[[[self locations] objectAtIndex:[indexPath row]] name]];
    
    return cell;
}



@end
