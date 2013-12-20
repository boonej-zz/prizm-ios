//
//  STKConnection.m
//  STK
//
//  Created by Joe Conway on 3/26/13.
//  Copyright (c) 2013 STable Kernel. All rights reserved.
//

#import "STKConnection.h"
#import "NSError+STKConnection.h"


NSString * const STKConnectionErrorDomain = @"STKConnectionErrorDomain";

static NSMutableArray *sharedConnectionList = nil;

@interface STKConnection ()
@property (nonatomic) int statusCode;
@property (nonatomic, weak) NSURLSessionDataTask *internalConnection;
@property (nonatomic, strong) NSMutableDictionary *internalArguments;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *endpoint;

@end

@implementation STKConnection
@dynamic parameters;

- (id)initWithBaseURL:(NSURL *)url endpoint:(NSString *)endpoint
{
    self = [super init];
    if (self) {
        [self setMethod:STKConnectionMethodGET];
        _internalArguments = [[NSMutableDictionary alloc] init];
        _baseURL = url;
        _endpoint = endpoint;
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
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[self baseURL]
                                               resolvingAgainstBaseURL:NO];
    [components setPath:[self endpoint]];
    
    NSMutableString *queryString = [[NSMutableString alloc] init];
    NSArray *allKeys = [[self internalArguments] allKeys];
    for(NSString *key in allKeys) {
        NSString *value = [[self internalArguments] objectForKey:key];
        
        [queryString appendFormat:@"%@=%@", key, [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        if(key != [allKeys lastObject])
            [queryString appendString:@"&"];
    }
    [components setPercentEncodedQuery:queryString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[components URL]];
    [req setHTTPMethod:@{@(STKConnectionMethodGET) : @"GET",
                         @(STKConnectionMethodPOST) : @"POST",
                         @(STKConnectionMethodDELETE) : @"DELETE",
                         @(STKConnectionMethodPUT) : @"PUT"}[@([self method])]];

    
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
    if (!sharedConnectionList)
        sharedConnectionList = [[NSMutableArray alloc] init];
    
    // Add the connection to the array so it doesn't get destroyed
    [sharedConnectionList addObject:self];
    
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

- (void)addAuthorizationDictionary:(NSDictionary *)dict
{
    
}

- (void)addQueryValue:(NSString *)value forKey:(NSString *)key
{
    if(!value || !key)
        return;
    
    [_internalArguments setObject:value forKey:key];
}

- (void)setParameters:(NSDictionary *)parameters
{
    [_internalArguments removeAllObjects];
    for(NSString *key in parameters) {
        NSString *val = [parameters objectForKey:key];
        [_internalArguments setObject:val
                               forKey:key];
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
        if([objectKeyOrBlock isKindOfClass:[NSString class]]) {
            
            NSString *stringValue = [object valueForKeyPath:key];
            if(!stringValue) {
                success = NO;
                [missingKeys addObject:key];
            } else {
                [[self internalArguments] setObject:stringValue
                                             forKey:objectKeyOrBlock];
            }
        } else {
            NSString *initialValue = [object valueForKey:key];
            if(!initialValue) {
                success = NO;
                [missingKeys addObject:key];
            } else {
                NSDictionary * (^block)(id value) = objectKeyOrBlock;
                NSDictionary *result = block([object valueForKeyPath:key]);
                for(NSString *internalKey in result) {
                    [[self internalArguments] setObject:[result objectForKey:internalKey]
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
    NSLog(@"Request FAILED -> \nRequest: %@ - %@\nResponse: %d\n", [self request], [[self request] HTTPMethod], [self statusCode]);
#endif

    // Pass the error from the connection to the completionBlock
    if ([self completionBlock]) {
     /*   NSMutableDictionary *d = [[error userInfo] mutableCopy];
        NSString *desc = [d objectForKey:NSLocalizedDescriptionKey];
        if(desc) {
            [d setObject:@[desc] forKey:@"ErrorList"];
        } else {
            [d setObject:@[@"There was a problem with the connection. Make sure you have internet access and try again."]
                           forKey:@"ErrorList"];
        }*/
        
        [self completionBlock](nil, error);
    }
    // Destroy this connection
    [sharedConnectionList removeObject:self];
}

- (void)handleSuccess:(NSData *)data
{
#ifdef DEBUG
    NSLog(@"Request Finished -> \nRequest: %@ - %@\nResponse: %d\n%@", [self request], [[self request] HTTPMethod], [self statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif


// FIRST CHECK: RESPONSE CODE
    NSError *statusCodeError = nil;
    if ([self statusCode] >= 400) {
        statusCodeError = [NSError errorWithDomain:STKConnectionServiceErrorDomain
                                              code:STKConnectionErrorCodeBadRequest
                                          userInfo:nil];
        if ([self completionBlock]) {
            [self completionBlock](nil, statusCodeError);
        }
        [sharedConnectionList removeObject:self];
        return;
    }

    id rootObject = nil;
    NSError *jsonParsingError;
    NSDictionary *jsonObject = nil;

// SECOND CHECK: VALID JSON
    if([data length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0
                                                       error:&jsonParsingError];
        if (jsonParsingError) {
            if ([self completionBlock]) {
                [self completionBlock](nil, [NSError errorWithDomain:STKConnectionServiceErrorDomain
                                                            code:STKConnectionErrorCodeParseFailed
                                                        userInfo:nil]);
            }
            [sharedConnectionList removeObject:self];
            return;
        }
    }
    
    NSDictionary *responseValue = [jsonObject objectForKey:@"response"];
    
// THIRD CHECK: For Success from Server
    BOOL success = [[responseValue objectForKey:@"success"] boolValue];
    if(!success) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[responseValue objectForKey:@"message"]
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error;
        error = [NSError errorWithDomain:STKConnectionServiceErrorDomain
                                    code:STKConnectionErrorCodeRequestFailed
                                userInfo:userInfo];
        if ([self completionBlock]) {
            [self completionBlock](nil, error);
        }
        [sharedConnectionList removeObject:self];
        return;
    }
    
    NSDictionary *internalData = [responseValue objectForKey:@"data"];
    // If success, construct json object. If failure construct error
    if([self jsonRootObject]) {
        [[self jsonRootObject] readFromJSONObject:internalData];
        rootObject = [self jsonRootObject];
    } else if ([self entityName]) {
        if(![self context]) {
            @throw [NSException exceptionWithName:@"STKConnection No Context" reason:@"Trying to instantiate entity without context" userInfo:nil];
        }
        
        id obj = nil;
        if([self existingMatchMap]) {
            NSMutableArray *predicates = [NSMutableArray array];
            for(NSString *key in [self existingMatchMap]) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"%K == %@", key, [internalData valueForKeyPath:[[self existingMatchMap] objectForKey:key]]];
                [predicates addObject:p];
            }
            NSPredicate *p = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
            NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
            [req setPredicate:p];
            
            NSArray *results = [[self context] executeFetchRequest:req error:nil];
            if([results count] == 1) {
                obj = [results firstObject];
            } else {
                obj = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                    inManagedObjectContext:[self context]];
            }
        } else {
            obj = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                inManagedObjectContext:[self context]];
        }
        
        [obj readFromJSONObject:internalData];
        rootObject = obj;
    } else {
        rootObject = internalData;
    }
    
    // Then, pass the root object to the completion block - remember,
    // this is the block that the controller supplied.
    if ([self completionBlock])
        [self completionBlock](rootObject, nil);
    
    // Now, destroy this connection
    [sharedConnectionList removeObject:self];
}

+ (void)cancelAllConnections {
	
	for (STKConnection *connection in [sharedConnectionList copy]) {
		[connection.internalConnection cancel];
		[sharedConnectionList removeObjectAtIndex:0];
	}
}

@end
