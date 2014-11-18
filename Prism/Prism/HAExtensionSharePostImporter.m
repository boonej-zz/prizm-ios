//
//  HAExtensionSharePostImporter.m
//  Prizm
//
//  Created by Eric Kenny on 11/16/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAExtensionSharePostImporter.h"
#import "HAExtensionStore.h"

@implementation HAExtensionSharePostImporter

- (void)importPostFromShareExtension:(NSDictionary *)post
{
    if ([post count] == 0) {
        return;
    }
    else {
        [self.extensionStore createPostsFromExtensionDictionary:post];
    }
}

@end
