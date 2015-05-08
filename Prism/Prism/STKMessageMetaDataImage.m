//
//  STKMessageMetaDataImage.m
//  Prizm
//
//  Created by Jonathan Boone on 5/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKMessageMetaDataImage.h"


@implementation STKMessageMetaDataImage

@dynamic messageID;
@dynamic urlString;
@dynamic width;
@dynamic height;
@dynamic metaData;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"message_id": @"messageID",
             @"url": @"urlString",
             @"width": @"width",
             @"height": @"height"
             };
}

@end
