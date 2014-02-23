//
//  STKAuthorizationToken.h
//  Prism
//
//  Created by Joe Conway on 2/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKJSONObject.h"

@interface STKAuthorizationToken : NSObject <STKJSONObject>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSDate *expiration;
@property (nonatomic, strong) NSString *tokenType;

@end
