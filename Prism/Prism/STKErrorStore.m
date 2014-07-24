//
//  STKErrorStore.m
//  Prism
//
//  Created by Joe Conway on 12/19/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKErrorStore.h"
#import "STKUserStore.h"
#import "STKConnection.h"
#import "NSError+STKConnection.h"

@import Accounts;
@import CoreLocation;

NSString * const STKErrorUserDoesNotExist = @"user_does_not_exist";
NSString * const STKErrorBadPassword = @"invalid_user_credentials";
NSString * const STKErrorTrustLimit = @"unable_to_create_trust_100_limit";

NSString * const STKErrorInvalidRequest = @"invalid_request";
NSString * const STKErrorInvalidRegistration = @"invalid_registration";
NSString * const STKErrorStoreInvalidUserRequest = @"invalid_user_request";
NSString * const STKErrorStoreServerError = @"server_error";

@implementation STKErrorStore

+ (UIAlertView *)alertViewForError:(NSError *)err delegate:(id <UIAlertViewDelegate>)delegate
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[self errorTitleStringForError:err]
                                                 message:[self errorStringForError:err]
                                                delegate:delegate
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    return av;
}

+ (UIAlertView *)alertViewForErrorWithOriginMessage:(NSError *)err
                                           delegate:(id <UIAlertViewDelegate>)delegate
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[self errorTitleStringForError:err]
                                                 message:[self errorStringFromError:err]
                                                delegate:delegate
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    return av;
}

+ (NSDictionary *)errorTitleMap
{
    static NSMutableDictionary *errorMap = nil;
    if(!errorMap) {
        errorMap = [[NSMutableDictionary alloc] init];
        [errorMap setObject:@"Connection Error" forKey:NSURLErrorDomain];
    }
    
    return errorMap;
}

+ (NSDictionary *)errorMap
{
    static NSMutableDictionary *errorMap = nil;
    if(!errorMap) {
        errorMap = [[NSMutableDictionary alloc] init];
        
        [errorMap setObject:@{
            @(STKUserStoreErrorCodeMissingArguments) : @"The required data was not supplied.",
            @(STKUserStoreErrorCodeNoAccount) : @"No account exists for this social network. Please fill out your credentials in the Settings application.",
            @(STKUserStoreErrorCodeOAuth) : @"There was a problem authenticating your account.",
            @(STKUserStoreErrorCodeWrongAccount) : @"The account you tried to login with does not match the Facebook account you have set up in Settings.",
            @(STKUserStoreErrorCodeNoPassword) : @"The password for this account is unknown. Try logging in again."
        } forKey:STKUserStoreErrorDomain];
        [errorMap setObject:@{
            @(ACErrorUnknown) : @"Unknown issue relating your your account.",
            @(ACErrorAccountMissingRequiredProperty) : @"Not enough information was provided to authenticate your account.",
            @(ACErrorAccountAuthenticationFailed) : @"There was an issue authenticating your account.",
            @(ACErrorAccountTypeInvalid) : @"The account provided is invalid.",
            @(ACErrorAccountAlreadyExists) : @"This account already exists.",
            @(ACErrorAccountNotFound) : @"No account exists for this service. Please sign into the account in the Settings application.",
            @(ACErrorPermissionDenied) : @"Permission to access this information was denied.",
            @(ACErrorAccessInfoInvalid) : @"The accessed information is invalid.",
            @(ACErrorClientPermissionDenied) : @"Permission was denied.",
            @(ACErrorAccessDeniedByProtectionPolicy) : @"The protection policy denied access.",
            @(ACErrorCredentialNotFound) : @"The username and password for this account were not found.",
            @(ACErrorFetchCredentialFailed) : @"The username and password failed to access this account.",
            @(ACErrorStoreCredentialFailed) : @"This account could not be saved.",
            @(ACErrorRemoveCredentialFailed) : @"This account could not be deleted.",
            @(ACErrorUpdatingNonexistentAccount) : @"This account no longer exists.",
            @(ACErrorInvalidClientBundleID) : @"The application bundle identifier does not match."
        } forKey:ACErrorDomain];
        [errorMap setObject:@{
            @(STKConnectionErrorCodeBadRequest) : @"There was a problem with the server.",
            @(STKConnectionErrorCodeParseFailed) : @"The response from the server didn't make sense.",
            @(STKConnectionErrorCodeRequestFailed) : @"The requested information was not accessed successfully.",
            STKErrorUserDoesNotExist : @"Invalid user or password.",
            STKErrorBadPassword : @"Invalid user or password.",
            STKErrorInvalidRequest : @"There was a problem communicating with the server.",
            STKErrorInvalidRegistration : @"An account with this e-mail address already exists.",
            STKErrorStoreInvalidUserRequest : @"Invalid user.",
            STKErrorStoreServerError : @"There was a problem with the server. Please contact customer support."
        } forKey:STKConnectionServiceErrorDomain];
        [errorMap setObject:@{
            @"Any" : @"There was a problem communicating with the server. Ensure you have internet access and try again.",
            @(NSURLErrorCancelled) : @"Your request was cancelled."
        } forKey:NSURLErrorDomain];
        [errorMap setObject:@{
            @(kCLErrorDenied) : @"Prizm doesn't have access to your location. Please change this in the Settings application."
            } forKey:kCLErrorDomain];

    }
    
    return errorMap;
}

/*
 "error": "OAuthException",
 "error_description": "Error validating access token: The session has been invalidated because the user has changed the password."
 */

+ (NSString *)errorTitleStringForError:(NSError *)err
{
    NSString *title = [[self errorTitleMap] objectForKey:[err domain]];
    if(!title) {
        title = @"Error";
    }
    return title;
}

+ (NSString *)errorStringForError:(NSError *)err
{
    NSDictionary *domainErrors = [[self errorMap] objectForKey:[err domain]];
    NSDictionary *userInfo = [err userInfo];
    
    NSString *text = nil;
    if([userInfo objectForKey:@"error"]) {
        text = [domainErrors objectForKey:[userInfo objectForKey:@"error"]];
    } else {
        text = [domainErrors objectForKey:@([err code])];
    }
    
    if(!text) {
        text = [domainErrors objectForKey:@"Any"];
        if(!text) {
            text = [[err userInfo] objectForKey:@"error"];
        }
    }
    
    if(!text) {
        return [err localizedDescription];
    }
    
    return text;
}

+ (NSString *)errorStringFromError:(NSError *)err
{
    NSDictionary *userInfo = [err userInfo];
    if([userInfo objectForKey:@"error_description"]) {
        return [userInfo objectForKey:@"error_description"];
    }
    
    return [self errorStringForError:err];
}

@end
