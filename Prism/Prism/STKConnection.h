//
//  STKConnection.h
//
//  Created by Joe Conway on 3/26/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"

@import CoreData;

@interface STKConnection : NSObject
    <NSURLConnectionDataDelegate>

- (id)initWithRequest:(NSURLRequest *)req;

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);

@property (nonatomic, strong) id <STKJSONObject> jsonRootObject;

@property (nonatomic, strong) id <NSXMLParserDelegate> xmlRootObject;

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) void (^insertionBlock)(NSManagedObject *rootObject);
@property (nonatomic, strong) NSManagedObjectContext *context;

- (void)start;

+ (void)cancelAllConnections;

@end
