//
//  STKConnection.m
//  STK
//
//  Created by Joe Conway on 3/26/13.
//  Copyright (c) 2013 STable Kernel. All rights reserved.
//

#import "STKConnection.h"
#import "NSError+STKConnection.h"

static NSMutableArray *sharedConnectionList = nil;

@interface STKConnection ()
@property (nonatomic) int statusCode;
@property (nonatomic, strong) NSMutableData *container;
@property (nonatomic, strong) NSURLConnection *internalConnection;
@end

@implementation STKConnection

- (id)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        [self setRequest:req];
    }
    return self;
}

- (void)start
{
    // Initialize container for data collected from NSURLConnection
    [self setContainer:[[NSMutableData alloc] init]];
    
    // Spawn connection
    [self setInternalConnection:[[NSURLConnection alloc] initWithRequest:[self request]
                                                                delegate:self
                                                        startImmediately:YES]];
    // If this is the first connection started, create the array
    if (!sharedConnectionList)
        sharedConnectionList = [[NSMutableArray alloc] init];
    
    // Add the connection to the array so it doesn't get destroyed
    [sharedConnectionList addObject:self];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    //[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // Pass the error from the connection to the completionBlock
    if ([self completionBlock]) {
        // Let's massage a standard error into the Rheem format...
        NSMutableDictionary *d = [[error userInfo] mutableCopy];
        NSString *desc = [d objectForKey:NSLocalizedDescriptionKey];
        if(desc) {
            [d setObject:@[desc] forKey:@"ErrorList"];
        } else {
            [d setObject:@[@"There was a problem with the connection. Make sure you have internet access and try again."]
                           forKey:@"ErrorList"];
        }
        
        [self completionBlock](nil, [NSError errorWithDomain:[error domain]
                                                        code:[error code]
                                                    userInfo:d]);
    }
    // Destroy this connection
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
    
    [self setStatusCode:[r statusCode]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self container] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
#ifdef DEBUG
    NSLog(@"Request Finished -> \nRequest: %@ - %@\nResponse: %d\n%@", [self request], [[self request] HTTPMethod], [self statusCode], [[NSString alloc] initWithData:self.container encoding:NSUTF8StringEncoding]);
#endif

    // Rheem generally isn't supplying significant status codes. We should still check for >= 400
    NSError *statusCodeError;
    if (self.statusCode >= 400) {
        statusCodeError = [NSError errorWithDomain:STKConnectionServiceErrorDomain
                                              code:-2
                                          userInfo:nil];
        if ([self completionBlock]) {
            [self completionBlock](nil,statusCodeError);
        }
        [sharedConnectionList removeObject:self];
        return;
    }

    id rootObject = nil;
    
    // will return json object if jsonRootObject is supplied, entityName and context are supplied, or no jsonRootObject, entityName or context are supplied
    
    // Create a parser with the incoming data and let the root object parse
    // its contents
    NSError *jsonParsingError;
    NSDictionary *jsonObject = nil;
    
    
    if([[self container] length] > 0) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:[self container]
                                                     options:0
                                                       error:&jsonParsingError];
        if (jsonParsingError) {
            if ([self completionBlock]) {
                [self completionBlock](nil, [NSError errorWithDomain:STKConnectionServiceErrorDomain
                                                            code:-2
                                                        userInfo:nil]);
            }
            [sharedConnectionList removeObject:self];
            return;
        }
    }
    
    id errorAppearance = ([jsonObject isKindOfClass:[NSDictionary class]] ? [jsonObject objectForKey:@"error"] : nil);
    if(errorAppearance) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorAppearance
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error;
        error = [NSError errorWithDomain:STKConnectionServiceErrorDomain
                                    code:-1
                                userInfo:userInfo];
        if ([self completionBlock]) {
            [self completionBlock](nil, error);
        }
        [sharedConnectionList removeObject:self];
        return;
    }
    
    if(!jsonObject) {
        // If we got an empty response back, we were only checking for an error
        rootObject = nil;
    } else {
        // If success, construct json object. If failure construct error
        if ([[jsonObject objectForKey:@"Success"] boolValue])   {
            if([self jsonRootObject]) {
                [[self jsonRootObject] readFromJSONObject:jsonObject];
                rootObject = [self jsonRootObject];
            } else if ([self entityName]) {
                if(![self context]) {
                    @throw [NSException exceptionWithName:@"STKConnection No Context" reason:@"Trying to instantiate entity without context" userInfo:nil];
                }
                
                id obj = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                       inManagedObjectContext:[self context]];
                [obj readFromJSONObject:jsonObject];
                rootObject = obj;
            } else {
                rootObject = jsonObject;
            }
        } else {
            if ([self completionBlock]) {
                NSError *error = [NSError errorWithDomain:STKConnectionServiceErrorDomain code:-10 userInfo:jsonObject];
                [self completionBlock](nil,error);
            }
            [sharedConnectionList removeObject:self];
            return;
        }
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
