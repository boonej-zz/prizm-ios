//
//  STKPost.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKPost.h"
#import "STKUser.h"

NSString * const STKPostLocationLatitudeKey = @"location_lat";
NSString * const STKPostLocationLongitudeKey = @"location_long";
NSString * const STKPostLocationNameKey = @"location_name";
NSString * const STKPostURLKey = @"file_path";
NSString * const STKPostTextKey = @"body";
NSString * const STKPostTypeKey = @"post_type";

NSString * const STKPostVisibilityPublic = @"1";
NSString * const STKPostVisibilityTrust = @"2";
NSString * const STKPostVisibilityPrivate = @"3";

NSString * const STKPostTypeAspiration = @"1";
NSString * const STKPostTypeInspiration = @"2";
NSString * const STKPostTypeExperience = @"3";
NSString * const STKPostTypeAchievement = @"4";
NSString * const STKPostTypePassion = @"5";
NSString * const STKPostTypeAccolade = @"6";


@implementation STKPost

@dynamic commentCount, coordinate, creatorID, creatorName, creatorProfilePhotoURL, datePosted;
@dynamic externalSystemID, hashTagsData, imageURLString, likeCount, locationName, postID, text;
@dynamic type, user, profileID;
@dynamic referenceTimestamp;

@synthesize hashTags = _hashTags;

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSDictionary *d = @{@"lat" : @(coordinate.latitude), @"lon" : @(coordinate.longitude)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:d options:0 error:nil];
    [self willChangeValueForKey:@"coordinateData"];
    [self setValue:data forKey:@"coordinateData"];
    [self didChangeValueForKey:@"coordinateData"];
}

- (CLLocationCoordinate2D)coordinate
{
    NSData *data = [self valueForKey:@"coordinateData"];
    if(!data)
        return CLLocationCoordinate2DMake(0, 0);
    
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    CLLocationCoordinate2D coord;
    coord.latitude = [[d objectForKey:@"lat"] doubleValue];
    coord.longitude = [[d objectForKey:@"lon"] doubleValue];
    return coord;
}

- (NSError *)readFromJSONObject:(id)jsonObject
{
    
    [self bindFromDictionary:jsonObject keyMap:@{
                                                 @"post" : @"postID",
                                                 STKPostTextKey : @"text",
                                                 STKPostLocationNameKey : @"locationName",
                                                 @"created" : ^(id inValue) {
                                                     NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                                     [df setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
                                                     [self setDatePosted:[df dateFromString:inValue]];
                                                 },
                                                 @"created" : @"referenceTimestamp",
                                                 STKPostURLKey : @"imageURLString",
                                                 @"external_system" : @"externalSystemID",
                                                 @"like_count" : @"likeCount",
                                                 @"comment_count" : @"commentCount",
                                                 @"profile" : @"profileID"
    }];
    
    NSDictionary *creator = [jsonObject objectForKey:@"creator"];
    [self setCreatorID:[creator objectForKey:@"entity"]];
    NSString *firstName = [creator objectForKey:@"first_name"];
    NSString *lastName = [creator objectForKey:@"last_name"];
    [self setCreatorName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
    
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

- (NSArray *)hashTags
{
    if(!_hashTags) {
        if([[self hashTagsData] length] > 0) {
            _hashTags = [NSJSONSerialization JSONObjectWithData:[self hashTagsData]
                                                        options:0
                                                          error:nil];
        } else {
            _hashTags = @[];
        }
    }
    return _hashTags;
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
