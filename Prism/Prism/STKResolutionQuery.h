//
//  STKResolutionQuery.h
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKQueryObject.h"

@interface STKResolutionQuery : STKQueryObject

+ (STKResolutionQuery *)resolutionQueryForEntityName:(NSString *)entityName
                                       serverTypeKey:(NSString *)serverTypeKey
                                               field:(NSString *)field;


@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSString *serverTypeKey;
@property (nonatomic, strong) NSString *field;

@end
