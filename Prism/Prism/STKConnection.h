//
//  STKConnection.h
//
//  Created by Joe Conway on 3/26/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"

@import CoreData;

typedef enum {
    STKConnectionMethodGET,
    STKConnectionMethodPOST,
    STKConnectionMethodPUT,
    STKConnectionMethodDELETE
} STKConnectionMethod;

extern NSString * const STKConnectionErrorDomain;

typedef enum {
    STKConnectionErrorCodeBadRequest,
    STKConnectionErrorCodeParseFailed,
    STKConnectionErrorCodeRequestFailed
    
} STKConnectionErrorCode;

@interface STKConnection : NSObject

+ (void)cancelAllConnections;

- (id)initWithBaseURL:(NSURL *)url endpoint:(NSString *)endpoint;

@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic) STKConnectionMethod method;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *authorizationString;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);
@property (nonatomic, strong) NSData *HTTPBody;

@property (nonatomic, strong) id <STKJSONObject> jsonRootObject;

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, strong) NSDictionary *existingMatchMap;
@property (nonatomic, copy) void (^insertionBlock)(NSManagedObject *rootObject);
@property (nonatomic, strong) NSManagedObjectContext *context;

- (void)beginWithSession:(NSURLSession *)session;
- (void)beginWithSession:(NSURLSession *)session method:(STKConnectionMethod)method completionBlock:(void (^)(id obj, NSError *err))block;

- (void)postWithSession:(NSURLSession *)session completionBlock:(void (^)(id obj, NSError *err))block;
- (void)getWithSession:(NSURLSession *)session completionBlock:(void (^)(id obj, NSError *err))block;

// Verifies keys, returns YES if all keys are in object.
// Optionally pass missingKeysOut to see which keys are missing
// keyMap values can either be an NSString
// or ^ NSDictionary * (id value) block, where the NSDictionary is @{outputKey : value}
- (BOOL)addQueryObject:(id)object
           missingKeys:(NSArray **)missingKeysOut
            withKeyMap:(NSDictionary *)keyMap;

- (void)addQueryValue:(NSString *)value forKey:(NSString *)key;


@end
