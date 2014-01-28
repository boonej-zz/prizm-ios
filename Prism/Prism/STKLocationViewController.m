//
//  STKLocationViewController.m
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLocationViewController.h"
@import MapKit;

@interface STKLocationViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation STKLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
    [placemark setCoordinate:[self coordinate]];
    [[self mapView] addAnnotation:placemark];
    
    [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance([self coordinate], 50, 50)];
}

@end
