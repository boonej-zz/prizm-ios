//
//  STKFoursquareConnection.m
//  Prism
//
//  Created by Joe Conway on 1/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKFoursquareConnection.h"
#import "NSError+STKConnection.h"

@implementation STKFoursquareConnection
- (void)handleSuccess:(NSData *)data
{
#ifdef DEBUG
    NSLog(@"Request Finished -> \nRequest: %@ - %@\nResponse: %d\nData:%@", [self request], [[self request] HTTPMethod], (int)[self statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
    
    
    if ([self statusCode] >= 400) {
        [self reportFailureWithError:[NSError errorWithDomain:STKConnectionServiceErrorDomain
                                                         code:STKConnectionErrorCodeBadRequest
                                                     userInfo:nil]];
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
    
    NSDictionary *responseValue = [jsonObject objectForKey:@"response"];
/*    BOOL success = [[responseValue objectForKey:@"success"] boolValue];
    if(!success) {
        NSString *msg = [responseValue objectForKey:@"message"];
        
        // Intercept 'Not Authorized' at lowest level
        if([msg isEqualToString:@"Not Authorized"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:STKConnectionUnauthorizedNotification
                                                                object:self];
        }
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg
                                                             forKey:NSLocalizedDescriptionKey];
        [self reportFailureWithError:[NSError errorWithDomain:STKConnectionServiceErrorDomain
                                                         code:STKConnectionErrorCodeRequestFailed
                                                     userInfo:userInfo]];
        return;
    }*/
    
    
    NSError *err = nil;
    id rootObject = nil;
    id internalData = responseValue;
    if(![self modelGraph]) {
        rootObject = [self populateModelObjectWithData:internalData error:&err];
    } else {
        rootObject = [self populateModelGraphWithData:internalData error:&err];
    }
    
    if(err) {
        [self reportFailureWithError:err];
        return;
    }
    
    // Then, pass the root object to the completion block - remember,
    // this is the block that the controller supplied.
    if ([self completionBlock])
        [self completionBlock](rootObject, nil);
    
    // Now, destroy this connection
    [[STKConnection activeConnections] removeObject:self];
}
@end
