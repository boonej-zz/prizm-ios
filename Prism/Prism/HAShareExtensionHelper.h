//
//  HAShareExtensionHelper.h
//  Prizm
//
//  Created by Eric Kenny on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HAShareExtensionHelper : NSObject

+ (HAShareExtensionHelper *)helper;

- (void)checkForUserDefaults;
- (void)createPostsFromDefaults;

@end
