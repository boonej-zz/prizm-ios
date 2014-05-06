//
//  STKFetchDescription.h
//  Prism
//
//  Created by Joe Conway on 5/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKQueryObject.h"

@interface STKFetchDescription : NSObject

@property (nonatomic, weak) id referenceObject;
@property (nonatomic) STKQueryObjectPage direction;
@property (nonatomic, strong) NSDictionary *filterDictionary;

@end
