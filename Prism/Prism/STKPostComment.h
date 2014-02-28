//
//  STKPostComment.h
//  Prism
//
//  Created by Joe Conway on 2/28/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"
@class STKUser;

@interface STKPostComment : NSObject <STKJSONObject>

@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;

@end
