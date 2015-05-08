//
//  STKMessageMetaData.m
//  Prizm
//
//  Created by Jonathan Boone on 5/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKMessageMetaData.h"
#import "STKMessage.h"
#import "STKMessageMetaDataImage.h"


@implementation STKMessageMetaData

@dynamic messageID;
@dynamic linkDescription;
@dynamic title;
@dynamic message;
@dynamic image;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"message_id": @"messageID",
             @"description": @"linkDescription",
             @"title": @"title",
             @"image": [STKBind bindMapForKey:@"image" matchMap:@{@"messageID": @"message_id"}]
             };
}

@end
