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

NSString * const STKErrorUserDoesNotExist = @"user_does_not_exist";
NSString * const STKErrorBadPassword = @"invalid_user_credentials";

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
            STKErrorUserDoesNotExist : @"The specified user does not exist.",
            STKErrorBadPassword : @"The password does not match."
        } forKey:STKConnectionServiceErrorDomain];
        [errorMap setObject:@{
            @"Any" : @"There was a problem communicating with the server. Ensure you have internet access and try again."
        } forKey:NSURLErrorDomain];
    }
    
    return errorMap;
}

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
        return [domainErrors objectForKey:[userInfo objectForKey:@"error"]];
    } else {
        text = [domainErrors objectForKey:@([err code])];
        if(!text) {
            text = [domainErrors objectForKey:@"Any"];
            if(!text) {
                text = [[err userInfo] objectForKey:NSLocalizedDescriptionKey];
                if(!text) {
                    text = @"There was an unexpected error.";
                } else {
                    userInfo = nil;
                }
            }
        }
    }
    
    if([userInfo count] > 0)
        return [NSString stringWithFormat:@"%@ (%@)", text, [[err userInfo] objectForKey:NSLocalizedDescriptionKey]];
    
    return text;
}

@end
