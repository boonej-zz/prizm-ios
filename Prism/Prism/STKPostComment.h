//
//  STKPostComment.h
//  Prism
//
//  Created by Joe Conway on 2/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"
@class STKUser, STKPost;

@interface STKPostComment : NSManagedObject <STKJSONObject>

@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) int likeCount;

@property (nonatomic, strong) STKUser *creator;
@property (nonatomic, strong) NSSet *likes;
@property (nonatomic, strong) STKPost *post;

- (BOOL)isLikedByUser:(STKUser *)u;

@end
