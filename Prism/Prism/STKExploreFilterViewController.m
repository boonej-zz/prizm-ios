//
//  STKExploreFilterViewController.m
//  Prism
//
//  Created by DJ HAYDEN on 6/25/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKExploreFilterViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTextImageCell.h"
#import "STKImageCollectionViewCell.h"
#import "STKPost.h"
#import "STKUser.h"

@interface STKExploreFilterViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *categoryCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *councilCollectionView;
@property (nonatomic, strong) NSArray *categoryItems;
@property (nonatomic, strong) NSArray *councilItems;

@end

@implementation STKExploreFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _categoryItems = @[
                           @{@"title" : @"Aspiration", @"key" : STKPostTypeAspiration,
                             @"image" : [UIImage imageNamed:@"category_aspiration_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_aspirations_selected"]},
                           @{@"title" : @"Passion", @"key" : STKPostTypePassion,
                             @"image" : [UIImage imageNamed:@"category_passions_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_passions_selected"]},
                           @{@"title" : @"Experience", @"key" : STKPostTypeExperience,
                             @"image" : [UIImage imageNamed:@"category_experiences_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_experiences_selected"]},
                           @{@"title" : @"Achievement", @"key" : STKPostTypeAchievement,
                             @"image" : [UIImage imageNamed:@"category_achievements_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_achievements_selected"]},
                           @{@"title" : @"Inspiration", @"key" : STKPostTypeInspiration,
                             @"image" : [UIImage imageNamed:@"category_inspiration_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_inspiration_selected"]},
                           @{@"title" : @"Filter All", @"key" : @"filterall",
                             @"image" : [UIImage imageNamed:@"category_filterall"],
                             @"selectedImage" : [UIImage imageNamed:@"category_filterall"]}
                           ];
        _councilItems = @[
                          @{@"title" : @"Community", @"key" : STKUserSubTypeCommunity,
                            @"image" : [UIImage imageNamed:@"council_community"]},
                          @{@"title" : @"Corporate", @"key" : STKUserSubTypeCompany,
                            @"image" : [UIImage imageNamed:@"council_companies"]},
                          @{@"title" : @"Education", @"key" : STKUserSubTypeEducation,
                            @"image" : [UIImage imageNamed:@"council_education"]},
                          @{@"title" : @"Foundation", @"key" : STKUserSubTypeFoundation,
                            @"image" : [UIImage imageNamed:@"council_foundations"]},
                          @{@"title" : @"Military", @"key" : STKUserSubTypeMilitary,
                            @"image" : [UIImage imageNamed:@"council_military"]},
                          @{@"title" : @"Luminary", @"key" : STKUserSubTypeLuminary,
                            @"image" : [UIImage imageNamed:@"council_luminaires"]},
                          ];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self categoryCollectionView] registerNib:[UINib nibWithNibName:@"STKTextImageCell" bundle:nil]
                    forCellWithReuseIdentifier:@"STKTextImageCell"];
    [[self categoryCollectionView] setBackgroundColor:[UIColor clearColor]];
    [[self categoryCollectionView] setScrollEnabled:NO];
    
    [[self councilCollectionView] registerNib:[UINib nibWithNibName:@"STKTextImageCell" bundle:nil]
                   forCellWithReuseIdentifier:@"STKTextImageCell"];
    [[self councilCollectionView] setBackgroundColor:[UIColor clearColor]];
    [[self councilCollectionView] setScrollEnabled:NO];
    
}

- (void)reloadData
{
    [[self categoryCollectionView] reloadData];
    [[self councilCollectionView] reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == [self categoryCollectionView]) {
        return [[self categoryItems] count];
    }
    
    
    return [[self councilItems] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == [self categoryCollectionView]) {
        NSDictionary *item = [[self categoryItems] objectAtIndex:[indexPath row]];
        STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                               forIndexPath:indexPath];
        [[cell label] setText:[item objectForKey:@"title"]];
        [[cell label] setTextColor:STKTextColor];
        [[cell imageView] setImage:[item objectForKey:@"selectedImage"]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        if([[item objectForKey:@"key"] isEqualToString:[[self filters] objectForKey:@"type"]]) {
            [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
        }
        
        return cell;
    }
    
    if(collectionView == [self councilCollectionView]) {
        NSDictionary *item = [[self councilItems] objectAtIndex:[indexPath row]];
        STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                               forIndexPath:indexPath];
        [[cell label] setText:[item objectForKey:@"title"]];
        [[cell label] setTextColor:STKTextColor];
        [[cell imageView] setImage:[item objectForKey:@"image"]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        if([[item objectForKey:@"key"] isEqualToString:[[self filters] objectForKey:@"subtype"]]) {
            [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *current = [[self filters] mutableCopy];
    if(!current) {
        current = [NSMutableDictionary dictionary];
    }
    NSDictionary *item;
    if(collectionView == [self categoryCollectionView]) {
        item = [[self categoryItems] objectAtIndex:[indexPath row]];
        NSString *val = [item objectForKey:@"key"];
        
        if([val isEqualToString:@"filterall"]) {
            [current removeAllObjects];
        } else if([[[self filters] objectForKey:@"type"] isEqualToString:val]) {
            [current removeObjectForKey:@"type"];
        } else {
            [current setObject:val forKey:@"type"];
        }
        
    }
    
    if(collectionView == [self councilCollectionView]) {
        item = [[self councilItems] objectAtIndex:[indexPath row]];
        NSString *val = [item objectForKey:@"key"];
        if([[[self filters] objectForKey:@"subtype"] isEqualToString:val]) {
            [current removeObjectForKey:@"subtype"];
        } else {
            [current setObject:val forKey:@"subtype"];
        }
    }
    [self setFilters:[current copy]];
    [[self delegate] exploreFilterViewController:self didUpdateFilters:[self filters]];
    [self reloadData];
}


@end
