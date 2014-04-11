//
//  STKContainQuery.h
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKQueryObject.h"

@interface STKContainQuery : STKQueryObject

+ (STKContainQuery *)containQueryForField:(NSString *)field
                                keyValues:(NSDictionary *)dict;

+ (STKContainQuery *)containQueryForField:(NSString *)field
                                      key:(NSString *)key
                                    value:(NSString *)value;

@property (nonatomic, strong) NSString *field;

// Using this will replace key/value
@property (nonatomic, strong) NSDictionary *keyValues;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;

@end
