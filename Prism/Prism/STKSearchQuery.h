//
//  STKSearchQuery.h
//  Prism
//
//  Created by Joe Conway on 4/6/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKQueryObject.h"

@interface STKSearchQuery : STKQueryObject
@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) NSString *value;

+ (STKSearchQuery *)searchQueryForField:(NSString *)field value:(NSString *)value;

@end
