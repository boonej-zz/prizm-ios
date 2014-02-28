//
//  STKRequestItem.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKRequestItem.h"
#import "STKUserStore.h"

NSString * const STKRequestTypeTrust = @"1";
NSString * const STKRequestTypeAccolade = @"2";

NSString * const STKRequestStatusPending = @"1";
NSString * const STKRequestStatusAccepted = @"2";
NSString * const STKRequestStatusRejected = @"3";
NSString * const STKRequestStatusBlocked = @"4";


@implementation STKRequestItem


/*
 
 @property (nonatomic, strong) STKProfile *requestingProfile;
 @property (nonatomic, strong) NSDate *dateCreated;
 @property (nonatomic, strong) NSString *requestID;
 @property (nonatomic, strong) NSString *type;
 @property (nonatomic, strong) NSString *status;
 
*/
- (NSError *)readFromJSONObject:(id)jsonObject
{
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSSSSS"];
    }
    [self bindFromDictionary:jsonObject
                      keyMap:@{
                               @"request" : @"requestID",
                               @"request_type" : @"type",
                               @"request_status" : @"status",
                               @"recorded" : ^(id inValue) {
                                    [self setDateCreated:[df dateFromString:inValue]];
    }}];
    

//    [self setRequestingProfile:[[STKUserStore store] profileForProfileDictionary:[jsonObject objectForKey:@"requesting_profile"]]];
    return nil;
}

@end
