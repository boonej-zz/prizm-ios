//
//  STKFoursquareLocation.m
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKFoursquareLocation.h"

@implementation STKFoursquareLocation

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self setName:[jsonObject objectForKey:@"name"]];

    NSDictionary *loc = [jsonObject objectForKey:@"location"];
    _location.latitude = [[loc objectForKey:@"lat"] floatValue];
    _location.longitude = [[loc objectForKey:@"lng"] floatValue];
    
    _address = [loc objectForKey:@"address"];
    
    return nil;
}

- (NSString *)description
{
    return [self name];
}

@end
