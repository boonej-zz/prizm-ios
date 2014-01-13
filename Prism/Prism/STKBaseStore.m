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
NSString * const STKLookupTypeGender = @"STKGender";
NSString * const STKLookupTypeSocial = @"STKExternalSystem";

NSString * const STKUserEndpointGenderList = @"/common/ajax/get_genders.php";
NSString * const STKUserEndpointSocialList = @"/common/ajax/get_external_systems.php";


@interface STKBaseStore () <NSURLSessionDelegate>



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
        
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
        
        
        [self fetchLookupValues];

    }
    return self;
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)req
{
    return [[self context] executeFetchRequest:req error:nil];
}

- (void)fetchLookupValues
{
    [self fetchLookupValuesForEntity:@"STKGender" endpoint:STKUserEndpointGenderList keyPath:@"genders.gender"];
    [self fetchLookupValuesForEntity:@"STKExternalSystem" endpoint:STKUserEndpointSocialList keyPath:@"external_systems.external_system"];
}

- (void)fetchLookupValuesForEntity:(NSString *)entity endpoint:(NSString *)endpoint keyPath:(NSString *)keyPath
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    NSString *keyGrouping = [keys objectAtIndex:0];
    NSString *keyName = [keys objectAtIndex:1];
    
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:entity];
    if([[[self context] executeFetchRequest:r error:nil] count] == 0) {
        STKConnection *c = [self connectionForEndpoint:endpoint];
        [c getWithSession:[self session]
          completionBlock:^(NSDictionary *lookupValues, NSError *err) {
              NSArray *allValues = [lookupValues objectForKey:keyGrouping];
              for(NSDictionary *value in allValues) {
                  NSManagedObject *o = [NSEntityDescription insertNewObjectForEntityForName:entity
                                                                     inManagedObjectContext:[self context]];
                  [o setValue:[value objectForKey:@"label"] forKey:@"label"];
                  [o setValue:[value objectForKey:keyName] forKey:@"identifier"];
              }
              [[self context] save:nil];
          }];
    }
}

- (STKConnection *)connectionForEndpoint:(NSString *)endpoint
{
    STKConnection *c = [[STKConnection alloc] initWithBaseURL:[[self class] baseURL]
                                                     endpoint:endpoint];
    
    return c;
}


- (NSString *)transformLookupValue:(NSString *)lookupValue forType:(NSString *)type
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:type];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"label like[cd] %@", lookupValue]];
    NSManagedObject *result = [[[self context] executeFetchRequest:fetch error:nil] firstObject];
    
    return [result valueForKey:@"identifier"];
}


@end
