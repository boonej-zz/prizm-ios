//
//  STKPost.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKPost.h"
#import "STKUser.h"
#import "STKUserStore.h"
#import "STKPostComment.h"

NSString * const STKPostLocationLatitudeKey = @"location_latitude";
NSString * const STKPostLocationLongitudeKey = @"location_longitude";
NSString * const STKPostLocationNameKey = @"location_name";

NSString * const STKPostVisibilityKey = @"scope";
NSString * const STKPostHashTagsKey = @"hash_tags";

NSString * const STKPostURLKey = @"file_path";
NSString * const STKPostTextKey = @"text";
NSString * const STKPostTypeKey = @"category";
NSString * const STKPostOriginIDKey = @"origin_post_id";

NSString * const STKPostVisibilityPublic = @"public";
NSString * const STKPostVisibilityPrivate = @"private";
NSString * const STKPostVisibilityTrust = @"trust";

NSString * const STKPostTypeAspiration = @"aspiration";
NSString * const STKPostTypeInspiration = @"inspiration";
NSString * const STKPostTypeExperience = @"experience";
NSString * const STKPostTypeAchievement = @"achievement";
NSString * const STKPostTypePassion = @"passion";
NSString * const STKPostTypePersonal = @"personal";
NSString * const STKPostTypeAccolade = @"accolade";

NSString * const STKPostStatusDeleted = @"deleted";

@interface STKPost ()
@property (nonatomic) double locationLatitude;
@property (nonatomic) double locationLongitude;
@end

@implementation STKPost
@dynamic coordinate;
@dynamic hashTags, imageURLString, uniqueID, datePosted, locationLatitude, locationLongitude, locationName,
visibility, status, repost, referenceTimestamp, text, comments, commentCount, creator, originalPost, likes, likeCount,
type, fInverseFeed;
- (NSError *)readFromJSONObject:(id)jsonObject
{
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }

    [self bindFromDictionary:jsonObject keyMap:@{
                                                 @"_id" : @"uniqueID",
                                                 STKPostTypeKey : @"type",

                                                 STKPostURLKey : @"imageURLString",
                                                 STKPostLocationNameKey : @"locationName",
                                                 STKPostLocationLatitudeKey : @"locationLatitude",
                                                 STKPostLocationLongitudeKey : @"locationLongitude",
                                                 STKPostVisibilityKey : @"visibility",
                                                 @"status" : @"status",
                                                 @"is_repost" : @"repost",
                                                 STKPostTextKey : @"text",
                                                 
                                                 
                                                 @"likes_count" : @"likeCount",
                                                 @"comments_count" : @"commentCount",
                                                 @"hash_tags" : @{STKJSONBindFieldKey : @"hashTags", STKJSONBindMatchDictionaryKey : @{@"title" : @"title"}},
                                                 
                                                 @"creator" : @{STKJSONBindFieldKey : @"creator", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"likes" : @{STKJSONBindFieldKey : @"likes", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 @"comments" : @{STKJSONBindFieldKey : @"comments", STKJSONBindMatchDictionaryKey : @{@"uniqueID" : @"_id"}},
                                                 
                                                 @"create_date" : ^(NSString *inValue) {
                                                    [self setReferenceTimestamp:inValue];
                                                    [self setDatePosted:[df dateFromString:inValue]];
                                                 }
    }];
    
    return nil;
}

- (BOOL)isPostLikedByUser:(STKUser *)u
{
    return [[self likes] member:u] != nil;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self setLocationLatitude:coordinate.latitude];
    [self setLocationLongitude:coordinate.longitude];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self locationLatitude],
                                      [self locationLongitude]);
}

- (UIImage *)typeImage
{
    return [[self class] imageForType:[self type]];
}

+ (UIImage *)imageForType:(NSString *)t
{
    NSDictionary *m = @{STKPostTypeAchievement : @"category_achievements_sm",
                        STKPostTypeAspiration : @"category_aspirations_sm",
                        STKPostTypeExperience : @"category_experiences_sm",
                        STKPostTypeInspiration : @"category_inspiration_sm",
                        STKPostTypePassion : @"category_passions_sm"};
    
    NSString *imageName = m[t];
    
    if(imageName) {
        return [UIImage imageNamed:imageName];
    }
    
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"0x%x %@ %@", (int)self, [self uniqueID], [self text]];
}

@end
