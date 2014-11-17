//
//  STKInsight.m
//  Prizm
//
//  Created by Jonathan Boone on 10/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInsight.h"
#import "STKHashTag.h"
#import "STKUser.h"


@implementation STKInsight

@dynamic uniqueID;
@dynamic createDate;
@dynamic text;
@dynamic filePath;
@dynamic likesCount;
@dynamic dislikesCount;
@dynamic tagsCount;
@dynamic hashTagsCount;
@dynamic creator;
@dynamic hashTags;
@dynamic tags;
@dynamic title;
@dynamic link;
@dynamic linkTitle;

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id" : @"uniqueID",
             @"text" : @"text",
             @"likes_count" : @"likesCount",
             @"dislikes_count": @"dislikesCount",
             @"file_path": @"filePath",
             @"title": @"title",
             @"hash_tags" : [STKBind bindMapForKey:@"hashTags" matchMap:@{@"title" : @"title"}],
             @"tags" : [STKBind bindMapForKey:@"tags" matchMap:@{@"uniqueID" : @"_id"}],
             @"creator" : [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID" : @"_id"}],
             @"create_date" : [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"link": @"link",
             @"link_title": @"linkTitle"
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

- (NSURL *)linkURL
{
    if (self.link) {
        return [NSURL URLWithString:self.link];
    } else {
        return nil;
    }
}

@end
