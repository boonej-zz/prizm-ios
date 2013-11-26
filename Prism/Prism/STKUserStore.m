//
//  STKUserStore.m
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKUserStore.h"
#import "STKUser.h"
#import "STKActivityItem.h"
#import "STKRequestItem.h"
#import "STKPost.h"

@import CoreData;
@import Accounts;

@interface STKUserStore ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation STKUserStore

+ (STKUserStore *)store
{
    static STKUserStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKUserStore alloc] init];
    });
    return store;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"User"
                                                                                                                withExtension:@"momd"]];

        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"user.db"];
        NSError *error = nil;
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[NSURL fileURLWithPath:dbPath]
                                    options:nil
                                      error:&error]) {
            [NSException raise:@"Open failed" format:@"Reason %@", [error localizedDescription]];
        }
        
        _context = [[NSManagedObjectContext alloc] init];
        [[self context] setPersistentStoreCoordinator:psc];
        [[self context] setUndoManager:nil];
        
        _accountStore = [[ACAccountStore alloc] init];
        
        [self buildTemporaryData];
    }
    return self;
}

- (void)fetchAccountsForDevice:(void (^)(NSArray *accounts, NSError *err))block
{
    ACAccountType *type = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [[self accountStore] requestAccessToAccountsWithType:type
                                                 options:@{
                                                           ACFacebookAppIdKey : @"744512878911220",
                                                           ACFacebookPermissionsKey : @[
                                                                   @"email", @"user_birthday",
                                                                   @"user_education_history",
                                                                   @"user_hometown",
                                                                   @"user_location",
                                                                   @"user_photos",
                                                                   @"user_religion_politics"
                                                            ]
                                                           }
                                              completion:^(BOOL granted, NSError *error) {
                                                  if(granted) {
                                                      NSArray *accounts = [[self accountStore] accountsWithAccountType:type];
                                                      block(accounts, nil);
                                                  } else {
                                                      block(nil, error);
                                                  }
                                              }];
}

- (void)fetchFeedForCurrentUser:(void (^)(NSArray *posts, NSError *error, BOOL moreComing))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block([[[self currentUser] posts] array], nil, NO);
    }];
}

- (void)fetchActivityForCurrentUser:(void (^)(NSArray *activity, NSError *error, BOOL moreComing))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block([[[self currentUser] activityItems] array], nil, NO);
    }];
}

- (void)buildTemporaryData
{
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:@"STKUser"];
    NSArray *a = [[self context] executeFetchRequest:r error:nil];
    if([a count] > 0) {
        [self setCurrentUser:[a objectAtIndex:0]];
        return;
    }
    
    STKUser *u = [NSEntityDescription insertNewObjectForEntityForName:@"STKUser"
                                               inManagedObjectContext:[self context]];
    [u setUserID:0];
    [u setUserName:@"Cedric Rogers"];
    [u setEmail:@"cedric@higheraltitude.co"];
    [u setGender:@"Male"];
    
    [self setCurrentUser:u];
    
    // reuqestItes, activityItems, posts
    
    NSArray *authors = @[@"University of Wisconsin", @"Cedric Rogers", @"Joe Conway", @"Rovane Durso",
                         @"Facebook", @"North Carolina State", @"Emory"];
    NSArray *iconURLStrings = @[@"https://www.etsy.com/storque/media/bunker/2008/10/DU_Wisconsin_logo-tn.jpg",
                               @"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg",
                               @"http://stablekernel.com/images/joe.png",
                               @"https://pbs.twimg.com/profile_images/3500227034/2ad776b09c64e9ff677c91dd55a18472_bigger.jpeg",
                               @"http://marketingland.com/wp-content/ml-loads/2013/05/facebook-logo-new-300x300.png",
                               @"http://www.logotypes101.com/logos/953/28D5E04946B566AA97E4770658F48F55/NC_State_University1.png",
                               @"http://www.comacc.org/training/PublishingImages/Emory_Logo.jpg"];
                               
    NSArray *origins = @[@"Instagram", @"Facebook", @"Prism", @"Twitter"];
    NSArray *dates = @[[NSDate date], [NSDate dateWithTimeIntervalSinceNow:-100000], [NSDate dateWithTimeIntervalSinceNow:-2000]];
    NSArray *images = @[@"http://socialmediamamma.com/wp-content/uploads/2012/11/now-is-the-time-inspirational-quote-inspiring-quotes-www.socialmediamamma.com_.jpg",
                        @"http://socialmediamamma.com/wp-content/uploads/2012/11/dont-be-afraid-to-live-inspiring-quotes-Inspirational-quotes-Gaynor-Parke-www.socialmediamamma.com_.jpg"];
                        
    NSArray *hashTags = @[@"hash", @"tag", @"bar", @"foo", @"baz", @"school", @"inspiration"];
    
    srand(time(NULL));
    
    for(int i = 0; i < 10; i++) {
        STKPost *p = [NSEntityDescription insertNewObjectForEntityForName:@"STKPost"
                                                   inManagedObjectContext:[self context]];
        int idx = rand() % [authors count];
        [p setAuthorName:authors[idx]];
        [p setIconURLString:iconURLStrings[idx]];

        idx = rand() % [origins count];
        [p setPostOrigin:origins[idx]];
        
        [p setAuthorUserID:0];
        
        idx = rand() % [dates count];
        [p setDatePosted:dates[idx]];
        
        int count = rand() % 4;
        NSMutableArray *tags = [NSMutableArray array];
        for(int j = 0; j < count; j++) {
            idx = rand() % [hashTags count];
            [tags addObject:hashTags[idx]];
        }
        [p setHashTagsData:[NSJSONSerialization dataWithJSONObject:tags options:0 error:nil]];

        idx = rand() % [images count];
        [p setImageURLString:images[idx]];
        [p setUser:u];
    }
    
    for(int i = 0; i < 5; i++) {
        STKActivityItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"STKActivityItem"
                                                              inManagedObjectContext:[self context]];
        [item setUser:u];
        [item setUserID:0];
        [item setUserName:@"Cedric Rogers"];
        [item setProfileImageURLString:@"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg"];
        [item setRecent:(BOOL)(rand() % 2)];
        [item setType:(STKActivityItemType)(rand() % 5)];
        [item setReferenceImageURLString:images[rand() % [images count]]];
        [item setDate:dates[rand() % [dates count]]];
    }
    for(int i = 0; i < 5; i++) {
        STKRequestItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"STKRequestItem"
                                                              inManagedObjectContext:[self context]];
        [item setUser:u];
        [item setUserID:0];
        [item setUserName:@"Cedric Rogers"];
        [item setProfileImageURLString:@"https://pbs.twimg.com/profile_images/2420162558/image_bigger.jpg"];
        [item setType:STKRequestItemTypeTrust];
        [item setDateReceived:dates[rand() % [dates count]]];
        if(rand() % 2 == 0) {
            [item setAccepted:(BOOL)(rand() % 2)];
            [item setDateConfirmed:dates[rand() % [dates count]]];
        }
        
    }
    [[self context] save:nil];
}

@end
