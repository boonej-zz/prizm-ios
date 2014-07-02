//
//  STKLocationListViewController.h
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKFoursquareLocation.h"

@class STKLocationListViewController;

@protocol STKLocationListViewControllerDelegate <NSObject>

- (void)locationListViewController:(STKLocationListViewController *)lvc
                     choseLocation:(STKFoursquareLocation *)loc;

@end

@interface STKLocationListViewController : UITableViewController

- (id)initWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@property (nonatomic, weak) id <STKLocationListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *locations;
@end
