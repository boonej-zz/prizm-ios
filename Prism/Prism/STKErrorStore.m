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
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                       otherButtonTitles:nil];
    return av;
}

+ (UIAlertView *)alertViewForErrorWithOriginMessage:(NSError *)err
                                           delegate:(id <UIAlertViewDelegate>)delegate
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[self errorTitleStringForError:err]
                                                 message:[self errorStringFromError:err]
                                                delegate:delegate
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"standard dismiss button title")
                                       otherButtonTitles:nil];
    return av;
}

+ (NSDictionary *)errorTitleMap
{
    static NSMutableDictionary *errorMap = nil;
    if(!errorMap) {
        errorMap = [[NSMutableDictionary alloc] init];
        [errorMap setObject:NSLocalizedString(@"Connection Error", @"Connection error title") forKey:NSURLErrorDomain];
    }
    
    return errorMap;
}

+ (NSDictionary *)errorMap
{
    static NSMutableDictionary *errorMap = nil;
    if(!errorMap) {
        errorMap = [[NSMutableDictionary alloc] init];
        
        [errorMap setObject:@{
            @(STKUserStoreErrorCodeMissingArguments) : NSLocalizedString(@"The required data was not supplied.", @"missing data"),
            @(STKUserStoreErrorCodeNoAccount) : NSLocalizedString(@"No account exists for this social network. Please fill out your credentials in the Settings application.", @"no account for social network"),
            @(STKUserStoreErrorCodeOAuth) : NSLocalizedString(@"There was a problem authenticating your account.", @"problem authenticating account"),
            @(STKUserStoreErrorCodeWrongAccount) : NSLocalizedString(@"The account you tried to login with does not match the Facebook account you have set up in Settings.", @"facebook accounts do not match"),
            @(STKUserStoreErrorCodeNoPassword) : NSLocalizedString(@"The password for this account is unknown. Try logging in again.", @"cannot find password, please try again")
        } forKey:STKUserStoreErrorDomain];
        [errorMap setObject:@{
            @(ACErrorUnknown) : NSLocalizedString(@"Unknown issue relating your your account.", @"unknown account issue"),
            @(ACErrorAccountMissingRequiredProperty) : NSLocalizedString(@"Not enough information was provided to authenticate your account.", @"not enough auth information"),
            @(ACErrorAccountAuthenticationFailed) : NSLocalizedString(@"There was an issue authenticating your account.", @"issue authenticating"),
            @(ACErrorAccountTypeInvalid) : NSLocalizedString(@"The account provided is invalid.", @"invalid account"),
            @(ACErrorAccountAlreadyExists) : NSLocalizedString(@"This account already exists.", @"account already exists"),
            @(ACErrorAccountNotFound) : NSLocalizedString(@"No account exists for this service. Please sign into the account in the Settings application.", @"no account for service"),
            @(ACErrorPermissionDenied) : NSLocalizedString(@"Permission to access this information was denied.", @"permission denied to access information"),
            @(ACErrorAccessInfoInvalid) : NSLocalizedString(@"The accessed information is invalid.", @"invalid information"),
            @(ACErrorClientPermissionDenied) : NSLocalizedString(@"Permission was denied.", @"permission denied"),
            @(ACErrorAccessDeniedByProtectionPolicy) : NSLocalizedString(@"The protection policy denied access.", @"permission denied by protection policy"),
            @(ACErrorCredentialNotFound) : NSLocalizedString(@"The username and password for this account were not found.", @"no username or password found"),
            @(ACErrorFetchCredentialFailed) : NSLocalizedString(@"The username and password failed to access this account.", @"username or password failed to get access to account"),
            @(ACErrorStoreCredentialFailed) : NSLocalizedString(@"This account could not be saved.", @"could not save account"),
            @(ACErrorRemoveCredentialFailed) : NSLocalizedString(@"This account could not be deleted.", @"could not delete account"),
            @(ACErrorUpdatingNonexistentAccount) : NSLocalizedString(@"This account no longer exists.", @"account no longer exists"),
            @(ACErrorInvalidClientBundleID) : NSLocalizedString(@"The application bundle identifier does not match.", @"app bundle identifier does not match")
        } forKey:ACErrorDomain];
        [errorMap setObject:@{
            @(STKConnectionErrorCodeBadRequest) : NSLocalizedString(@"There was a problem with the server.", @"bad request"),
            @(STKConnectionErrorCodeParseFailed) : NSLocalizedString(@"The response from the server didn't make sense.", @"bad response"),
            @(STKConnectionErrorCodeRequestFailed) : NSLocalizedString(@"The requested information was not accessed successfully.", @"unable to access information"),
            STKErrorUserDoesNotExist : NSLocalizedString(@"Invalid user or password.", @"invalid user or password"),
            STKErrorBadPassword : NSLocalizedString(@"Invalid user or password.", @"invalid user or password"),
            STKErrorInvalidRequest : NSLocalizedString(@"There was a problem communicating with the server.", @"problem communicating with server"),
            STKErrorInvalidRegistration : NSLocalizedString(@"An account with this e-mail address already exists.", @"email address already being used"),
            STKErrorStoreInvalidUserRequest : NSLocalizedString(@"Invalid user.", @"invalid user"),
            STKErrorStoreServerError : NSLocalizedString(@"There was a problem with the server. Please contact customer support.", @"server issue, contact support")
        } forKey:STKConnectionServiceErrorDomain];
        [errorMap setObject:@{
            @"Any" : NSLocalizedString(@"There was a problem communicating with the server. Ensure you have internet access and try again.", @"server issue, check connection"),
            @(NSURLErrorCancelled) : NSLocalizedString(@"Your request was cancelled.", @"request cancelled")
        } forKey:NSURLErrorDomain];
        [errorMap setObject:@{
            @(kCLErrorDenied) : NSLocalizedString(@"Prizm doesn't have access to your location. Please change this in the Settings application.", @"location services off")
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
        title = NSLocalizedString(@"Error", @"generic error title");
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
