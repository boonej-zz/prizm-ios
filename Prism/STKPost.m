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

NSString * const STKPostHashTagsKey = @"hash_tags";

NSString * const STKPostURLKey = @"file_path";
NSString * const STKPostTextKey = @"text";
NSString * const STKPostTypeKey = @"category";

NSString * const STKPostVisibilityPublic = @"public";
NSString * const STKPostVisibilityPrivate = @"private";

NSString * const STKPostTypeAspiration = @"aspiration";
NSString * const STKPostTypeInspiration = @"inspiration";
NSString * const STKPostTypeExperience = @"experience";
NSString * const STKPostTypeAchievement = @"achievement";
NSString * const STKPostTypePassion = @"passion";
NSString * const STKPostTypeAccolade = @"accolade";


@implementation STKPost


- (NSError *)readFromJSONObject:(id)jsonObject
{
    [self bindFromDictionary:jsonObject keyMap:@{
                                                 @"_id" : @"postID",
                                                 STKPostTextKey : @"text",
                                                 STKPostTypeKey : @"type",
                                                 STKPostLocationNameKey : @"locationName",
                                                 @"create_date" : @"referenceTimestamp",
                                                 STKPostURLKey : @"imageURLString",
                                                 @"external_system" : @"externalSystemID",
                                                 @"likes_count" : @"likeCount",
                                                 @"comments_count" : @"commentCount",
                                                 @"hash_tags" : @"hashTags"
    }];
    
    NSDictionary *creator = [jsonObject objectForKey:@"creator"];
    if([self creator]) {
        [[self creator] readFromJSONObject:creator];
    } else {
        STKUser *u = [[STKUser alloc] init];
        [u readFromJSONObject:creator];
        [self setCreator:u];
    }

    NSArray *likes = [[jsonObject objectForKey:@"likes"] valueForKey:@"_id"];
    if([likes containsObject:[[[STKUserStore store] currentUser] userID]]) {
        [self setPostLikedByCurrentUser:YES];
    }
    
    NSArray *comments = [jsonObject objectForKey:@"comments"];
    NSMutableArray *commentObjects = [NSMutableArray array];
    for(NSDictionary *d in comments) {
        STKPostComment *c = [[STKPostComment alloc] init];
        [c readFromJSONObject:d];
        [commentObjects addObject:c];
    }
    [self setComments:[commentObjects copy]];
    
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    [self setDatePosted:[df dateFromString:[jsonObject objectForKey:@"create_date"]]];
    
     
    NSString *lat = [jsonObject objectForKey:STKPostLocationLatitudeKey];
    NSString *lon = [jsonObject objectForKey:STKPostLocationLongitudeKey];
    if(lat && lon && ![lat isKindOfClass:[NSNull class]] && ![lon isKindOfClass:[NSNull class]]) {
        CLLocationCoordinate2D coord;
        coord.latitude = [lat doubleValue];
        coord.longitude = [lon doubleValue];
        [self setCoordinate:coord];
    }
    
    return nil;
}

- (UIImage *)typeImage
{
    return [[self class] imageForType:[self type]];
}

+ (UIImage *)imageForType:(NSString *)t
{
    NSDictionary *m = @{STKPostTypeAchievement : @"category_achievements",
                        STKPostTypeAspiration : @"category_aspirations",
                        STKPostTypeExperience : @"category_experiences",
                        STKPostTypeInspiration : @"category_inspirations",
                        STKPostTypePassion : @"category_passion"};
    
    NSString *imageName = m[t];
    
    if(imageName) {
        return [UIImage imageNamed:imageName];
    }
    
    return nil;
}

@end
