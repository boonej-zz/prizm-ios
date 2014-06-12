//
//  STKQueryObject.h
//  Prism
//
//  Created by Joe Conway on 4/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    STKQueryObjectPageReload = -1,
    STKQueryObjectPageNewer = 0,
    STKQueryObjectPageOlder = 1
} STKQueryObjectPage;

typedef enum {
    STKQueryObjectSortAscending = 1,
    STKQueryObjectSortDescending = -1
} STKQueryObjectSort;

extern NSString * const STKQueryObjectFormatBasic;
extern NSString * const STKQueryObjectFormatShort;

extern NSString * const STKQueryObjectFilterExists;

@interface STKQueryObject : NSObject

@property (nonatomic, strong) NSString *format;

@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSDictionary *filters;

@property (nonatomic, strong) NSString *pageKey;
@property (nonatomic, strong) NSString *pageValue;
@property (nonatomic) STKQueryObjectPage pageDirection;

@property (nonatomic, strong) NSString *sortKey;
@property (nonatomic) STKQueryObjectSort sortOrder;

@property (nonatomic) int limit;

@property (nonatomic, strong) NSMutableArray *subqueries;

- (void)addSubquery:(STKQueryObject *)obj;

- (NSDictionary *)dictionaryRepresentation;

@end
