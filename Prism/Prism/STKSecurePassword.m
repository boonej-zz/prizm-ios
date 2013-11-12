//
//  STKSecurePassword.m
//
//  Created by Joe Conway on 5/20/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//

#import "STKSecurePassword.h"
#import <Security/Security.h>

NSString *STKSecurityDefaultService()
{
    return [[NSBundle mainBundle] bundleIdentifier];
}


NSString *STKSecurityGetPassword(NSString *username)
{
    return STKSecurityGetPasswordWithOptions(username, @{(__bridge id)kSecAttrService : STKSecurityDefaultService()});
}

NSError *STKSecurityStorePassword(NSString *username, NSString *password)
{
    return STKSecurityStorePasswordWithOptions(username, password, @{(__bridge id)kSecAttrService : STKSecurityDefaultService()});
}

void STKSecurityDeletePassword(NSString *username)
{
    STKSecurityDeletePasswordWithOptions(username, @{(__bridge id)kSecAttrService : STKSecurityDefaultService()});
}

NSString *STKSecurityGetPasswordWithOptions(NSString *username, NSDictionary *options)
{
    if(!username || ![options objectForKey:(__bridge id)kSecAttrService])
        return nil;
    
    NSMutableDictionary *opts = [@{
                                    (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrAccount : username,
                                    (__bridge id)kSecReturnData : (__bridge id)kCFBooleanTrue
                                 } mutableCopy];
    [opts addEntriesFromDictionary:options];
    
    CFTypeRef resultDataUntyped = nil;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)opts, &resultDataUntyped);
    
    if(err == noErr) {
        NSData *passwordData = (__bridge NSData *)resultDataUntyped;
        NSString *password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        CFRelease(resultDataUntyped);
        
        return password;
    }
    
    if(resultDataUntyped)
        CFRelease(resultDataUntyped);
    
    return nil;
    
}

NSError *STKSecurityStorePasswordWithOptions(NSString *username, NSString *password, NSDictionary *options)
{
    if(!username || !password) {
        @throw [NSException exceptionWithName:@"STKSecurePasswordException"
                                       reason:[NSString stringWithFormat:@"Trying to store NULL value for username or password (options=%@ username=%@ password=%@", options, username, password]
                                     userInfo:nil];
        return nil;
    }
    
    if(![options objectForKey:(__bridge id)kSecAttrService]) {
        @throw [NSException exceptionWithName:@"STKSecurePasswordException"
                                       reason:@"You forgot to include the key kSecAttrService when storing a password"
                                     userInfo:nil];
        return nil;
    }
    
    NSMutableDictionary *opts =  [@{
                                    (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrAccount : username,
                                    (__bridge id)kSecAttrAccessible : (__bridge id)kSecAttrAccessibleWhenUnlocked,
                                    (__bridge id)kSecAttrLabel : [NSString stringWithFormat:@"STKSecurityPassword-%@:%@", [options objectForKey:(__bridge id)kSecAttrService], username]
                                  } mutableCopy];
    [opts addEntriesFromDictionary:options];
    
    
    OSStatus err = noErr;
    NSString *existingPassword = STKSecurityGetPasswordWithOptions(username, opts);
    if(existingPassword) {
        err = SecItemUpdate((__bridge CFDictionaryRef)opts, (__bridge CFDictionaryRef)@{(__bridge id)kSecValueData : [password dataUsingEncoding:NSUTF8StringEncoding]});
    } else {
        [opts setObject:[password dataUsingEncoding:NSUTF8StringEncoding]
                 forKey:(__bridge id)kSecValueData];
        err = SecItemAdd((__bridge CFDictionaryRef)opts, NULL);
    }
                                  
    if(err != noErr) {
        return [NSError errorWithDomain:@"STKSecurePasswordErrorDomain"
                                   code:err
                               userInfo:@{@"description" : @"Encountered error while storing password"}];
    }

    return nil;
}

void STKSecurityDeletePasswordWithOptions(NSString *username, NSDictionary *options)
{
    if(!username) {
        @throw [NSException exceptionWithName:@"STKSecurePasswordException"
                                       reason:[NSString stringWithFormat:@"Trying to delete NULL username password (options=%@ username=%@", options, username]
                                     userInfo:nil];
    }
    
    if(![options objectForKey:(__bridge id)kSecAttrService]) {
        @throw [NSException exceptionWithName:@"STKSecurePasswordException"
                                       reason:@"You forgot to include the key kSecAttrService when storing a password"
                                     userInfo:nil];
    }
    
    NSMutableDictionary *opts =  [@{
                                    (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrAccount : username
                                  } mutableCopy];
    [opts addEntriesFromDictionary:options];

    SecItemDelete((__bridge CFDictionaryRef)opts);
    
}
