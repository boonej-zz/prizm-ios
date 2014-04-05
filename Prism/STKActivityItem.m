//
//  STKActivityItem.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKActivityItem.h"
#import "STKUser.h"


@implementation STKActivityItem

@dynamic uniqueID, user, otherUser, recent, type, referenceImageURLString, date;


+ (NSString *)stringForActivityItemType:(STKActivityItemType)t
{
    switch (t) {
        case STKActivityItemTypeComment:
            return @"commented on";
        case STKActivityItemTypeFollow:
            return @"followed";
        case STKActivityItemTypeLike:
            return @"liked your post";
        case STKActivityItemTypeTrustAccepted:
            return @"accepted your trust";
    }
    return @"";
}

@end
