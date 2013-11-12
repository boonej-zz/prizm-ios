//
//  STKSecurePassword.h
//
//  Created by Joe Conway on 5/20/13.
//  Copyright (c) 2013 Stable Kernel. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif    

    NSString *STKSecurityDefaultService();

    NSString *STKSecurityGetPassword(NSString *username);
    NSError *STKSecurityStorePassword(NSString *username, NSString *password);
    void STKSecurityDeletePassword(NSString *username);
    
    NSString *STKSecurityGetPasswordWithOptions(NSString *username, NSDictionary *options);
    NSError *STKSecurityStorePasswordWithOptions(NSString *username, NSString *password, NSDictionary *options);
    void STKSecurityDeletePasswordWithOptions(NSString *username, NSDictionary *options);
    
#ifdef __cplusplus
}
#endif
