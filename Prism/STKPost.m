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

NSString * const STKPostLocationLatitudeKey = @"location_lat";
NSString * const STKPostLocationLongitudeKey = @"location_long";
NSString * const STKPostLocationNameKey = @"location_name";
NSString * const STKPostURLKey = @"file_path";
NSString * const STKPostTextKey = @"text";
NSString * const STKPostTypeKey = @"type";

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
                                                 @"like_count" : @"likeCount",
                                                 @"comment_count" : @"commentCount"
    }];
    
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-ddTHH:mm:ss.SSSZ"];
    }
    
    [self setDatePosted:[df dateFromString:[jsonObject objectForKey:@"create_date"]]];
    
    [self setImageURLString:[[self imageURLString] stringByReplacingOccurrencesOfString:@"\\" withString:@""]];
    
//    [self setRecepientProfile:[[STKUserStore store] profileForProfileDictionary:[jsonObject objectForKey:@"profile"]]];
//    [self setCreatorProfile:[[STKUserStore store] profileForProfileDictionary:[jsonObject objectForKey:@"posting_profile"]]];
     
    NSString *lat = [jsonObject objectForKey:STKPostLocationLatitudeKey];
    NSString *lon = [jsonObject objectForKey:STKPostLocationLongitudeKey];
    if(lat && lon && ![lat isKindOfClass:[NSNull class]] && ![lon isKindOfClass:[NSNull class]]) {
        CLLocationCoordinate2D coord;
        coord.latitude = [lat doubleValue];
        coord.longitude = [lat doubleValue];
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
