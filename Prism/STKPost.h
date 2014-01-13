//
//  STKPost.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STKJSONObject.h"

typedef enum : int16_t {
    STKPostTypeAspiration,
    STKPostTypeInspiration,
    STKPostTypeExperience,
    STKPostTypeAchievement,
    STKPostTypePassion,
    STKPostTypeAccolade
} STKPostType;

@class STKUser;


/*
 "post":"27",
 "title":"post",
 "body":"Abcd",
 "location_name":null,
 "location_long":null,
 "location_lat":null,
 "visibility_type":"1",
 "profile":"15",
 "shared_post":null,
 "creator":{"entity":"27","first_name":"a","last_name":"b"},
 "created":"2014-01-10 19:11:45.463049",
 "modifier":"27",
 "modified":"2014-01-10 19:11:45.463049",
 "file_name":null,
 "file_path":"https:\/s3.amazonaws.com\/higheraltitude.prism\/20140110071141_LbR tbblaNW6oaA4dyvnvg==.jpg",
 "link_title":null,
 "link_body":null,
 "link_thumbnail":null,
 "link_address":null,
 "external_system":null,
 "like_count":"0",
 "comment_count":"0"}
 
 */

@interface STKPost : NSManagedObject <STKJSONObject>

@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * postOrigin;
@property (nonatomic) int32_t authorUserID;
@property (nonatomic, retain) NSDate * datePosted;
@property (nonatomic, retain) NSString * iconURLString;
@property (nonatomic, retain) NSData * hashTagsData;
@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic) STKPostType type;

@property (nonatomic, retain) STKUser *user;

@property (nonatomic, readonly) NSArray *hashTags;

- (UIImage *)typeImage;

+ (UIImage *)imageForType:(STKPostType)t;

@end
