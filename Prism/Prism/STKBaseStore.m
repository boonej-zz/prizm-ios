//
//  STKBaseStore.m
//  Prism
//
//  Created by Joe Conway on 12/26/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKBaseStore.h"
#import "STKConnection.h"


NSString * const STKUserBaseURLString = @"http://prism.neadwerx.com";

@interface STKBaseStore () <NSURLSessionDelegate>

@property (nonatomic, strong) NSManagedObjectContext *lookupContext;

@end

@implementation STKBaseStore

+ (STKBaseStore *)store
{
    static STKBaseStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKBaseStore alloc] init];
    });
    
    return store;
}

+ (NSURL *)baseURL
{
    return [NSURL URLWithString:STKUserBaseURLString];
}

- (id)init
{
    self = [super init];
    if(self) {
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
        
        
        NSString *lookupPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"lookup.sqlite"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:lookupPath]) {
            [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"lookup" ofType:@"sqlite"]
                                                    toPath:lookupPath
                                                     error:nil];
        }
        
        mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Lookup"
                                                                                          withExtension:@"momd"]];
        psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        error = nil;
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[NSURL fileURLWithPath:lookupPath]
                                    options:@{NSSQLitePragmasOption : @{@"journal_mode" : @"OFF"}}
                                      error:&error]) {
            [NSException raise:@"Open failed" format:@"Reason %@", [error localizedDescription]];
        }
        
        _lookupContext = [[NSManagedObjectContext alloc] init];
        [[self lookupContext] setPersistentStoreCoordinator:psc];
        [[self lookupContext] setUndoManager:nil];

        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
        
        
//

    }
    return self;
}


- (NSString *)labelForCode:(NSString *)code type:(STKLookupType)type
{
    NSString *entityName = @{@(STKLookupTypeCitizenship) : @"Citizenship",
                             @(STKLookupTypeCountry) : @"Country",
                             @(STKLookupTypeRace) : @"Race",
                             @(STKLookupTypeRegion) : @"Region",
                             @(STKLookupTypeReligion) : @"Religion"}[@(type)];
    

    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [req setPredicate:[NSPredicate predicateWithFormat:@"code == %d", [code intValue]]];
    
    NSArray *results = [[self lookupContext] executeFetchRequest:req error:nil];
    return [[results lastObject] valueForKey:@"label"];
}

- (NSNumber *)codeForLookupValue:(NSString *)lookupValue type:(STKLookupType)type
{
    NSString *entityName = @{@(STKLookupTypeCitizenship) : @"Citizenship",
                             @(STKLookupTypeCountry) : @"Country",
                             @(STKLookupTypeRace) : @"Race",
                             @(STKLookupTypeRegion) : @"Region",
                             @(STKLookupTypeReligion) : @"Religion"}[@(type)];

    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if(type == STKLookupTypeRegion) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"twoLetterCode == %@ or label == %@", lookupValue, lookupValue];
        [req setPredicate:pred];
    } else if(type == STKLookupTypeCountry) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"twoLetterCode == %@ or label == %@ or threeLetterCode == %@", lookupValue, lookupValue, lookupValue];
        [req setPredicate:pred];
    } else {
        [req setPredicate:[NSPredicate predicateWithFormat:@"label == %@", lookupValue]];
    }
    
    NSArray *results = [[self lookupContext] executeFetchRequest:req error:nil];
    
    return [[results lastObject] valueForKey:@"code"];
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)req
{
    return [[self context] executeFetchRequest:req error:nil];
}

- (STKConnection *)connectionForEndpoint:(NSString *)endpoint
{
    STKConnection *c = [[STKConnection alloc] initWithBaseURL:[[self class] baseURL]
                                                     endpoint:endpoint];
    
    return c;
}



@end
