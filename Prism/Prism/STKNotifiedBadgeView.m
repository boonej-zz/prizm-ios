//
//  STKNotifiedBadgeView.m
//  Prism
//
//  Created by Joe Conway on 4/30/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKNotifiedBadgeView.h"
#import "STKUserStore.h"

@implementation STKNotifiedBadgeView

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationsUpdated:)
                                                     name:STKUserStoreActivityUpdateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationsUpdated:)
                                                     name:HAUnreadMessagesUpdated
                                                   object:nil];
    }
    return self;
}

- (void)notificationsUpdated:(NSNotification *)note
{
    NSNumber *n = [[note userInfo] objectForKey:STKUserStoreActivityUpdateCountKey];
    double orgCount = [[NSUserDefaults standardUserDefaults] doubleForKey:HAUnreadMessagesForOrgKey];
    double groupCount = [[NSUserDefaults standardUserDefaults] doubleForKey:HAUnreadMessagesForGroupsKey];
    double total = orgCount + groupCount + n.doubleValue;
    
    if(total > 0) {
        [self setHidden:NO];
    } else {
        [self setHidden:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
