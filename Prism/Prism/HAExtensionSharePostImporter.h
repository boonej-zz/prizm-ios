//
//  HAExtensionSharePostImporter.h
//  Prizm
//
//  Created by Eric Kenny on 11/16/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAExtensionStore;

@interface HAExtensionSharePostImporter : NSObject

@property (nonatomic, strong) HAExtensionStore *extensionStore;

- (void)importPostFromShareExtension:(NSDictionary *)post;

@end
