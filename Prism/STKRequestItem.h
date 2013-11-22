//
//  STKRequestItem.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKUser;

typedef enum STKRequestItemEnum : int16_t {
    STKRequestItemTypeTrust
} STKRequestItemType;


@interface STKRequestItem : NSManagedObject

@property (nonatomic) int32_t userID;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * profileImageURLString;
@property (nonatomic) STKRequestItemType type;
@property (nonatomic, retain) NSDate * dateReceived;
@property (nonatomic, retain) NSDate * dateConfirmed;
@property (nonatomic) BOOL accepted;
@property (nonatomic, retain) STKUser *user;

@end
