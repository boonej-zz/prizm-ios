//
//  STKExploreViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKExploreViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKExploreCell.h"

@interface STKExploreViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation STKExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_explore"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_explore_selected"]];
        [self setAutomaticallyAdjustsScrollViewInsets:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIEdgeInsets currentInset = [[self collectionView] contentInset];
    currentInset.top += [[self toolbar] bounds].size.height;
    [[self collectionView] setContentInset:currentInset];
    [[self collectionView] registerNib:[UINib nibWithNibName:@"STKExploreCell" bundle:nil]
            forCellWithReuseIdentifier:@"STKExploreCell"];
    [[self collectionView] setBackgroundColor:[UIColor clearColor]];
    [[self toolbar] setTranslucent:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STKExploreCell *c = (STKExploreCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKExploreCell"
                                                                        forIndexPath:indexPath];
    
    [[c imageView] setImage:[UIImage imageNamed:@"34"]];
    return c;
}

@end
