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
                           @{@"title" : @"Aspiration", STKPostTypeKey : STKPostTypeAspiration,
                             @"image" : [UIImage imageNamed:@"category_aspiration_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_aspirations_selected"]},
                           @{@"title" : @"Passion", STKPostTypeKey : STKPostTypePassion,
                             @"image" : [UIImage imageNamed:@"category_passions_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_passions_selected"]},
                           @{@"title" : @"Experience", STKPostTypeKey : STKPostTypeExperience,
                             @"image" : [UIImage imageNamed:@"category_experiences_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_experiences_selected"]},
                           @{@"title" : @"Achievement", STKPostTypeKey : STKPostTypeAchievement,
                             @"image" : [UIImage imageNamed:@"category_achievements_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_achievements_selected"]},
                           @{@"title" : @"Inspiration", STKPostTypeKey : STKPostTypeInspiration,
                             @"image" : [UIImage imageNamed:@"category_inspiration_disabled"],
                             @"selectedImage" : [UIImage imageNamed:@"category_inspiration_selected"]},
                           @{@"title" : @"Filter All", STKPostTypeKey : @"filterall",
                             @"image" : [UIImage imageNamed:@"category_filterall"],
                             @"selectedImage" : [UIImage imageNamed:@"category_filterall"]}
                           ];
        _councilItems = @[
                          @{@"title" : @"Community", STKUserSubTypeKey : STKUserSubTypeCommunity,
                            @"image" : [UIImage imageNamed:@"council_community"]},
                          @{@"title" : @"Companies", STKUserSubTypeKey : STKUserSubTypeCompany,
                            @"image" : [UIImage imageNamed:@"council_companies"]},
                          @{@"title" : @"Education", STKUserSubTypeKey : STKUserSubTypeEducation,
                            @"image" : [UIImage imageNamed:@"council_education"]},
                          @{@"title" : @"Foundations", STKUserSubTypeKey : STKUserSubTypeFoundation,
                            @"image" : [UIImage imageNamed:@"council_foundations"]},
                          @{@"title" : @"Military", STKUserSubTypeKey : STKUserSubTypeMilitary,
                            @"image" : [UIImage imageNamed:@"council_military"]},
                          @{@"title" : @"Luminaires", STKUserSubTypeKey : STKUserSubTypeLuminary,
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
        
        if([item objectForKey:STKPostTypeKey] == [self filterSelected]) {
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
        
        if([item objectForKey:STKUserSubTypeKey] == [self filterSelected]) {
            [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item;
    if(collectionView == [self categoryCollectionView]) {
        item = [[self categoryItems] objectAtIndex:[indexPath row]];
        if([[self filterSelected] isEqualToString:[item objectForKey:STKPostTypeKey]]) {
            [self setFilterSelected:nil];
            
        } else {
            [self setFilterSelected:[item objectForKey:STKPostTypeKey]];
            
        }
        [[self delegate] didChangeFilter:STKExploreFilterTypeCategory withValue:[self filterSelected]];
    }
    
    if(collectionView == [self councilCollectionView]) {
        item = [[self councilItems] objectAtIndex:[indexPath row]];
        if([[self filterSelected] isEqualToString:[item objectForKey:STKUserSubTypeKey]]) {
            [self setFilterSelected:nil];
        } else {
            [self setFilterSelected:[item objectForKey:STKUserSubTypeKey]];
        }
        [[self delegate] didChangeFilter:STKExploreFilterTypeCouncil withValue:[self filterSelected]];
    }
    
    [self reloadData];
}


@end
