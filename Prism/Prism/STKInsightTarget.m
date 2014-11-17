//
//  STKInsightTarget.m
//  Prizm
//
//  Created by Jonathan Boone on 10/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInsightTarget.h"
#import "STKInsight.h"
#import "STKUser.h"


@implementation STKInsightTarget

@dynamic sentDate;
@dynamic liked;
@dynamic disliked;
@dynamic uniqueID;
@dynamic target;
@dynamic insight;
@dynamic filePath;

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id" : @"uniqueID",
             @"disliked" : @"disliked",
             @"liked": @"liked",
             @"target" : [STKBind bindMapForKey:@"target" matchMap:@{@"uniqueID" : @"_id"}],
             @"insight" : [STKBind bindMapForKey:@"insight" matchMap:@{@"uniqueID" : @"_id"}],
             @"create_date" : [STKBind bindMapForKey:@"sentDate" transform:STKBindTransformDateTimestamp],
             @"file_path": @"filePath"
             };
}

- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self setUniqueID:jsonObject];
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

@end
