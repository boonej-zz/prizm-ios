//
//  STKLocationViewController.h
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@interface STKLocationViewController : UIViewController

@property (nonatomic, strong) NSString *locationName;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
