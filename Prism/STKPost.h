//
//  STKPost.h
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum : int16_t {
    STKPostTypeAspiration,
    STKPostTypeInspiration,
    STKPostTypeExperience,
    STKPostTypeAchievement,
    STKPostTypePassion,
    STKPostTypeAccolade
} STKPostType;

@class STKUser;

@interface STKPost : NSManagedObject

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
