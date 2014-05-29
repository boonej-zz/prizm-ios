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

NSString * const STKPostDateCreatedKey = @"create_date";
NSString * const STKPostURLKey = @"file_path";
NSString * const STKPostTextKey = @"text";
NSString * const STKPostTypeKey = @"category";
NSString * const STKPostOriginIDKey = @"origin_post_id";
NSString * const STKPostAccoladeReceiverKey = @"accolade_target";

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

NSString * const STKPostHashTagURLScheme = @"hashtag";
NSString * const STKPostUserURLScheme = @"user";


@interface STKPost ()
@property (nonatomic) double locationLatitude;
@property (nonatomic) double locationLongitude;
@end

@implementation STKPost
@dynamic coordinate;
@dynamic hashTags, imageURLString, uniqueID, datePosted, locationLatitude, locationLongitude, locationName,
visibility, status, repost, text, comments, commentCount, creator, originalPost, likes, likeCount,
type, fInverseFeed, activities, derivativePosts, tags, creatorType, accoladeReceiver;
@dynamic fInverseProfile;


+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id" : @"uniqueID",
             @"type" : @"creatorType",
             STKPostTypeKey : @"type",
             
             STKPostURLKey : @"imageURLString",
             STKPostLocationNameKey : @"locationName",
             STKPostLocationLatitudeKey : @"locationLatitude",
             STKPostLocationLongitudeKey : @"locationLongitude",
             STKPostVisibilityKey : @"visibility",
             @"status" : @"status",
             @"is_repost" : @"repost",
             STKPostTextKey : @"text",
             
             @"accolade_target" : [STKBind bindMapForKey:@"accoladeReceiver"
                                                matchMap:@{@"uniqueID" : @"_id"}],
             
             @"likes_count" : @"likeCount",
             @"comments_count" : @"commentCount",
             @"hash_tags" : [STKBind bindMapForKey:@"hashTags" matchMap:@{@"title" : @"title"}],
             @"tags" : [STKBind bindMapForKey:@"tags" matchMap:@{@"uniqueID" : @"_id"}],
             
             @"creator" : [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID" : @"_id"}],
             @"likes" : [STKBind bindMapForKey:@"likes" matchMap:@{@"uniqueID" : @"_id"}],
             @"comments" : [STKBind bindMapForKey:@"comments" matchMap:@{@"uniqueID" : @"_id"}],
             
             @"origin_post_id" : [STKBind bindMapForKey:@"originalPost" matchMap:@{@"uniqueID" : @"_id"}],
             
             STKPostDateCreatedKey : [STKBind bindMapForKey:@"datePosted" transform:STKBindTransformDateTimestamp]
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
