//
//  STKMarkupUtilities.h
//  Prism
//
//  Created by Joe Conway on 5/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKUser;

@interface STKMarkupUtilities : NSObject
+ (UIImage *)imageForText:(NSString *)text;
+ (UIImage *)imageForUserTag:(NSString *)name attributes:(NSDictionary *)attributes;
+ (NSAttributedString *)userTagForUser:(STKUser *)user attributes:(NSDictionary *)attributes;
+ (NSAttributedString *)renderedTextForText:(NSString *)text attributes:(NSDictionary *)attributes;

@end
