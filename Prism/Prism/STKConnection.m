//
//  STKConnection.m
//  STK
//
//  Created by Joe Conway on 3/26/13.
//  Copyright (c) 2013 STable Kernel. All rights reserved.
//

#import "STKConnection.h"
#import "NSError+STKConnection.h"

NSString * const STKConnectionUnauthorizedNotification = @"STKConnectionUnauthorizedNotification";
NSString * const STKConnectionErrorDomain = @"STKConnectionErrorDomain";


@interface STKConnection ()
@property (nonatomic, weak) NSURLSessionDataTask *internalConnection;
@property (nonatomic, strong) NSMutableDictionary *internalArguments;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *endpoint;

@property (nonatomic) NSDate *beginTime;

@end

@implementation STKConnection
@dynamic parameters;

+ (NSMutableArray *)activeConnections
{
    static NSMutableArray *sharedConnectionList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConnectionList = [[NSMutableArray alloc] init];
    });
    return sharedConnectionList;
}

- (id)initWithBaseURL:(NSURL *)url endpoint:(NSString *)endpoint
{
    self = [super init];
    if (self) {
        [self setMethod:STKConnectionMethodGET];
        _internalArguments = [[NSMutableDictionary alloc] init];
        _baseURL = url;
        _endpoint = endpoint;
        if(!_endpoint)
            _endpoint = @"";
    }
    return self;
}

- (void)beginWithSession:(NSURLSession *)session method:(STKConnectionMethod)method completionBlock:(void (^)(id obj, NSError *err))block
{
    [self setCompletionBlock:block];
    [self setMethod:method];
    [self beginWithSession:session];
}

- (void)beginWithSession:(NSURLSession *)session
{
    _beginTime = [NSDate date];
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[self baseURL]
                                               resolvingAgainstBaseURL:NO];
    if([self identifiers]) {
        NSArray *fullArray = [@[[self endpoint]] arrayByAddingObjectsFromArray:[self identifiers]];
        NSString *pathIdentifier = [fullArray componentsJoinedByString:@"/"];
        [components setPath:pathIdentifier];
    } else {
        [components setPath:[self endpoint]];
    }
    
    NSMutableString *queryString = [[NSMutableString alloc] init];
    NSArray *allKeys = [[self internalArguments] allKeys];
    for(NSString *key in allKeys) {
        NSString *value = [[self internalArguments] objectForKey:key];
        NSString *v = nil;
        if([value rangeOfString:@"{"].location == NSNotFound) {
            v = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLArgumentAllowedCharacterSet]];
        } else {
            v = value;
        }

        [queryString appendFormat:@"%@=%@", key, v];
        if(key != [allKeys lastObject])
            [queryString appendString:@"&"];
    }
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    if([queryString length] > 0) {
        if([self method] == STKConnectionMethodPOST) {
            [req setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [components setPercentEncodedQuery:queryString];
        }
    }
    
    [req setURL:[components URL]];
    
    [req setHTTPMethod:@{@(STKConnectionMethodGET) : @"GET",
                         @(STKConnectionMethodPOST) : @"POST",
                         @(STKConnectionMethodDELETE) : @"DELETE",
                         @(STKConnectionMethodPUT) : @"PUT"}[@([self method])]];

    
    if(![req HTTPBody])
        [req setHTTPBody:[self HTTPBody]];
    
    if([self authorizationString])
        [req addValue:[self authorizationString] forHTTPHeaderField:@"Authorization"];
    
    _request = [req copy];

    NSURLSessionDataTask *dt = [session dataTaskWithRequest:[self request]
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if(error) {
                                                  [self handleError:error];
                                              } else {
                                                  NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
                                                  [self setStatusCode:[r statusCode]];
                                                  [self handleSuccess:data];
                                              }
                                          }];
    [self setInternalConnection:dt];

    // If this is the first connection started, create the array
    // Add the connection to the array so it doesn't get destroyed
    [[STKConnection activeConnections] addObject:self];
    
    [dt resume];
}

- (void)postWithSession:(NSURLSession *)session completionBlock:(void (^)(id obj, NSError *err))block
{
    [self setCompletionBlock:block];
    [self setMethod:STKConnectionMethodPOST];
    [self beginWithSession:session];
}

- (void)getWithSession:(NSURLSession *)session completionBlock:(void (^)(id obj, NSError *err))block
{
    [self setCompletionBlock:block];
    [self setMethod:STKConnectionMethodGET];
    [self beginWithSession:session];
}

- (void)addQueryValue:(id)value forKey:(NSString *)key
{
    if(!value || !key)
        return;
    if([value isKindOfClass:[NSString class]]) {
        [_internalArguments setObject:value forKey:key];
    } else if([value isKindOfClass:[NSDictionary class]]) {
        [self addQueryDictionary:value forKey:key];
    }
}

- (void)addQueryDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
    if(!key || !dict) {
        return;
    }
    
    NSMutableString *str = [[NSMutableString alloc] init];
    for(NSString *key in dict) {
        NSString *val = [dict objectForKey:key];
        [str appendFormat:@"%@:\"%@\",", key, [val stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLArgumentAllowedCharacterSet]]];
    }
    if([str length] > 0) {
        [str deleteCharactersInRange:NSMakeRange([str length] - 1, 1)];
    }
    
    NSString *formatted = [NSString stringWithFormat:@"{%@}", str];
    NSLog(@"%@", formatted);
    [self addQueryValue:formatted forKey:key];
}

- (void)setParameters:(NSDictionary *)parameters
{
    [_internalArguments removeAllObjects];
    for(NSString *key in parameters) {
        id val = [parameters objectForKey:key];
        [self addQueryValue:val forKey:key];
    }
}
- (BOOL)addQueryObject:(id)object
           missingKeys:(NSArray **)missingKeysOut
            withKeyMap:(NSDictionary *)keyMap
{
    BOOL success = YES;
    NSMutableArray *missingKeys = [[NSMutableArray alloc] init];
    for(NSString *key in keyMap) {
        id objectKeyOrBlock = [keyMap objectForKey:key];
        
        if([objectKeyOrBlock isKindOfClass:[NSString class]]
        || [objectKeyOrBlock isKindOfClass:[NSDictionary class]]) {
            id value = [object valueForKeyPath:key];
            if(!value) {
                success = NO;
                [missingKeys addObject:key];
            } else {
                [self addQueryValue:value
                             forKey:objectKeyOrBlock];
            }
        } else {
            // The assumption is that this is a block
            NSString *initialValue = [object valueForKey:key];
            if(!initialValue) {
                success = NO;
                [missingKeys addObject:key];
            } else {
                NSDictionary * (^block)(id value) = objectKeyOrBlock;
                NSDictionary *result = block([object valueForKeyPath:key]);
                for(NSString *internalKey in result) {
                    [self addQueryValue:[result objectForKey:internalKey]
                                 forKey:internalKey];
                }
            }
        }
    }
    if(missingKeysOut) {
        *missingKeysOut = [missingKeys copy];
    }
    return success;
}

- (NSDictionary *)parameters
{
    return [[self internalArguments] copy];
}


- (void)handleError:(NSError *)error
{
#ifdef DEBUG
    NSTimeInterval i = [[NSDate date] timeIntervalSinceDate:_beginTime];
    NSString *requestString = [[self request] description];
    if([[[self request] HTTPMethod] isEqualToString:@"POST"]) {
        requestString = [requestString stringByAppendingString:[[NSString alloc] initWithData:[[self request] HTTPBody] encoding:NSUTF8StringEncoding]];
    }
    NSLog(@"Request FAILED (%.3fs) -> \nRequest: %@ - %@\nResponse: %d\n", i, requestString, [[self request] HTTPMethod], [self statusCode]);
#endif

    [self reportFailureWithError:error];
}


- (void)reportFailureWithError:(NSError *)err
{
    if ([self completionBlock]) {
        [self completionBlock](nil, err);
    }
    [[STKConnection activeConnections] removeObject:self];
}

- (void)handleSuccess:(NSData *)data
{
#ifdef DEBUG
    NSTimeInterval i = [[NSDate date] timeIntervalSinceDate:_beginTime];
    NSString *requestString = [[self request] description];
    if([[[self request] HTTPMethod] isEqualToString:@"POST"]) {
        requestString = [requestString stringByAppendingString:[[NSString alloc] initWithData:[[self request] HTTPBody] encoding:NSUTF8StringEncoding]];
    }

    NSLog(@"Request Finished (%.3fs) -> \nRequest: %@ - %@\nResponse: %d\nData:%@", i, requestString, [[self request] HTTPMethod], [self statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif


    if ([self statusCode] >= 400) {
        if([self statusCode] == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:STKConnectionUnauthorizedNotification
                                                                object:self];
        }

        NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
        if([data length] > 0) {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0
                                                                         error:nil];
            NSDictionary *errObj = [jsonObject objectForKey:@"error"];
            if([errObj objectForKey:@"error"]) {
                [errDict setObject:[errObj objectForKey:@"error"]
                            forKey:@"error"];
            }
            if([errObj objectForKey:@"error_description"]) {
                [errDict setObject:[errObj objectForKey:@"error_description"]
                            forKey:@"error_description"];
            }
        }
        
        
        [self reportFailureWithError:[NSError errorWithDomain:STKConnectionServiceErrorDomain
                                                         code:STKConnectionErrorCodeRequestFailed
                                                     userInfo:errDict]];
        return;
    }

    NSDictionary *jsonObject = nil;
    if([data length] > 0) {
        NSError *error = nil;
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            [self reportFailureWithError:[NSError errorWithDomain:STKConnectionServiceErrorDomain
                                                             code:STKConnectionErrorCodeParseFailed
                                                         userInfo:[error userInfo]]];
            return;
        }
    }
    
    
    id rootObject = nil;

    NSDictionary *responseValue = [jsonObject objectForKey:@"metadata"];
    if(responseValue) {
        BOOL success = [[responseValue objectForKey:@"success"] boolValue];
        if(!success) {
            [self reportFailureWithError:[NSError errorWithDomain:STKConnectionServiceErrorDomain
                                                             code:STKConnectionErrorCodeRequestFailed
                                                         userInfo:nil]];
            return;
        }
        
        NSError *err = nil;
        id internalData = [jsonObject objectForKey:@"data"];
        
        if(![self modelGraph]) {
            rootObject = [self populateModelObjectWithData:internalData error:&err];
        } else {
            rootObject = [self populateModelGraphWithData:internalData error:&err];
        }
        
        if(![self shouldReturnArray]) {
            rootObject = [rootObject lastObject];
        }
        
        if(err) {
            [self reportFailureWithError:err];
            return;
        }
    }
    
    // Then, pass the root object to the completion block - remember,
    // this is the block that the controller supplied.
    if ([self completionBlock])
        [self completionBlock](rootObject, nil);
    
    // Now, destroy this connection
    [[STKConnection activeConnections] removeObject:self];
}

- (id)populateModelGraphWithData:(id)incomingData error:(NSError **)err
{
    return [self populateModelGraphWithData:incomingData
                                       node:[self modelGraph]
                                      error:err];
}

- (id)populateModelGraphWithData:(id)incomingData node:(id)node error:(NSError **)err
{
    // This is a messy way of handling the fact that you can't do a strict
    // class comparison for all of these class clusters.
    if ([node isKindOfClass:[NSArray class]]) {
        
        if(![incomingData isKindOfClass:[NSArray class]]) {
            *err = [NSError errorWithDomain:STKConnectionErrorDomain
                                       code:STKConnectionErrorCodeInvalidModelGraph
                                   userInfo:@{@"expected" : @"NSArray", @"received" : NSStringFromClass([incomingData class])}];
            return nil;
        }

        NSMutableArray *collection = [NSMutableArray array];
        NSString *internalNode = [node firstObject];
        for(id innerObj in incomingData) {
            NSError *internalError = nil;
            id parsedObject = [self populateModelGraphWithData:innerObj node:internalNode error:&internalError];
            if(internalError) {
                *err = internalError;
                return nil;
            }

            [collection addObject:parsedObject];
        }
        return collection;
    } else if([node isKindOfClass:[NSDictionary class]]) {
        
        if(![incomingData isKindOfClass:[NSDictionary class]]) {
            *err = [NSError errorWithDomain:STKConnectionErrorDomain
                                       code:STKConnectionErrorCodeInvalidModelGraph
                                   userInfo:@{@"expected" : @"NSDictionary", @"received" : NSStringFromClass([incomingData class])}];
            return nil;
        }
        
        NSMutableDictionary *collection = [NSMutableDictionary dictionary];
        for(NSString *key in node) {
            id innerNode = [node objectForKey:key];
            id incomingInnerObject = [incomingData objectForKey:key];
            
            NSError *internalError = nil;
            id parsedObject = [self populateModelGraphWithData:incomingInnerObject node:innerNode error:&internalError];
            if(internalError) {
                *err = internalError;
                return nil;
            }
            
            [collection setObject:parsedObject forKey:key];
        }
        return collection;
    } else {
        
        if(![incomingData isKindOfClass:[NSDictionary class]]) {
            *err = [NSError errorWithDomain:STKConnectionErrorDomain
                                       code:STKConnectionErrorCodeInvalidModelGraph
                                   userInfo:@{@"expected" : @"NSDictionary-Model or Model", @"received" : NSStringFromClass([incomingData class])}];
            return nil;
        }
        
        id obj = nil;
        if([node isKindOfClass:[NSString class]]) {
            if([self context])
                obj = [self instanceOfEntityForName:node data:incomingData];
            else
                obj = [[NSClassFromString(node) alloc] init];
        } else if ([node class] == node) {
            obj = [[node alloc] init];
        } else {
            obj = node;
        }
        
        NSError *resultErr = [obj readFromJSONObject:incomingData];
        if(resultErr) {
            *err = resultErr;
        }
        return obj;
    }
    return nil;
}

- (id)populateModelObjectWithData:(id)incomingData error:(NSError **)err
{
    if([self jsonRootObject]) {
        *err = [[self jsonRootObject] readFromJSONObject:incomingData];

        return [self jsonRootObject];
    } else if ([self entityName]) {
        
        id obj = [self instanceOfEntityForName:[self entityName] data:incomingData];
        
        *err = [obj readFromJSONObject:incomingData];
        
        return obj;
    }
    return incomingData;
}

- (NSManagedObject <STKJSONObject> *)instanceOfEntityForName:(NSString *)name data:(id)incomingData
{
    if(![self context]) {
        @throw [NSException exceptionWithName:@"STKConnection No Context" reason:@"Trying to instantiate entity without context" userInfo:nil];
    }
    
    id obj = nil;
    if([self existingMatchMap]) {
        NSMutableArray *predicates = [NSMutableArray array];
        for(NSString *key in [self existingMatchMap]) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"%K == %@", key, [incomingData valueForKeyPath:[[self existingMatchMap] objectForKey:key]]];
            [predicates addObject:p];
        }
        NSPredicate *p = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:name];
        [req setPredicate:p];
        
        NSArray *results = [[self context] executeFetchRequest:req error:nil];
        obj = [results firstObject];
    }
    
    if(!obj) {
        obj = [NSEntityDescription insertNewObjectForEntityForName:name
                                            inManagedObjectContext:[self context]];
    }
    return obj;
}


+ (void)cancelAllConnections {
	
	for (STKConnection *connection in [STKConnection activeConnections]) {
		[connection.internalConnection cancel];
	}
    [[STKConnection activeConnections] removeAllObjects];
}


@end
