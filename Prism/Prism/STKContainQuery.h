//
//  STKContainQuery.h
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKQueryObject.h"

@interface STKContainQuery : STKQueryObject

+ (STKContainQuery *)containQueryForField:(NSString *)field value:(NSString *)value;

@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) NSString *value;

@end
