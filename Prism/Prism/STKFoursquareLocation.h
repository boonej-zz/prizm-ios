//
//  STKFoursquareLocation.h
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"
@import CoreLocation;

@interface STKFoursquareLocation : NSObject <STKJSONObject>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *address;

@end
