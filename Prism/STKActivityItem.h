//
//  STKActivityItem.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef enum STKActivityItemEnum : int16_t {
    STKActivityItemTypeComment,
    STKActivityItemTypeLike,
    STKActivityItemTypeFollow,
    STKActivityItemTypeTrustAccepted
} STKActivityItemType;

@class STKUser;

@interface STKActivityItem : NSManagedObject

@property (nonatomic) int32_t userID;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * profileImageURLString;
@property (nonatomic) BOOL recent;
@property (nonatomic) STKActivityItemType type;
@property (nonatomic, retain) NSString * referenceImageURLString;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) STKUser *user;

+ (NSString *)stringForActivityItemType:(STKActivityItemType)t;

@end
