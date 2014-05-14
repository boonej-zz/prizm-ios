//
//  STKGraphViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKGraphViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"
#import "STKDateBar.h"
#import "STKPieChartView.h"
#import "STKGraphView.h"
#import "STKPost.h"
#import "STKGraphCell.h"

@interface STKGraphViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet STKGraphView *graphView;
@property (weak, nonatomic) IBOutlet STKPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet UITableView *percentTableView;
@property (weak, nonatomic) IBOutlet STKDateBar *dateBar;
@property (weak, nonatomic) IBOutlet UIView *underlayView;

@property (nonatomic, strong) NSArray *orderArray;
@property (nonatomic, strong) NSDictionary *typePercentages;
@property (nonatomic, strong) NSDictionary *typeColors;
@property (nonatomic, strong) NSDictionary *typeNames;
@property (nonatomic, strong) NSArray *graphValues;
@end

@implementation STKGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Graph"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_graph"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_graph_selected"]];
        [[self tabBarItem] setTitle:@"Graph"];

        [self setTypeColors:@{STKPostTypePassion : [UIColor redColor],
                              STKPostTypeAspiration : [UIColor blueColor],
                              STKPostTypeExperience : [UIColor greenColor],
                              STKPostTypeAchievement : [UIColor grayColor],
                              STKPostTypeInspiration : [UIColor yellowColor],
                              STKPostTypePersonal : [UIColor orangeColor]}];
        [self setOrderArray:@[STKPostTypePassion, STKPostTypeAspiration, STKPostTypeExperience, STKPostTypeAchievement, STKPostTypeInspiration, STKPostTypePersonal]];
    
        [self setTypeNames:@{STKPostTypePassion : @"Passion",
                              STKPostTypeAspiration : @"Aspiration",
                              STKPostTypeExperience : @"Experience",
                              STKPostTypeAchievement : @"Achievement",
                              STKPostTypeInspiration : @"Inspiration",
                              STKPostTypePersonal : @"Personal"}];
        
        [self setGraphValues:[self temporaryValues]];
    
    }
    return self;
}


- (void)menuWillAppear:(BOOL)animated
{
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            [[self underlayView] setAlpha:0.5];
        }];
    } else {
        [[self underlayView] setAlpha:0.5];
    }
}

- (void)menuWillDisappear:(BOOL)animated
{
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            [[self underlayView] setAlpha:0.0];
        }];
    } else {
        [[self underlayView] setAlpha:0.0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTypePercentages:@{STKPostTypePassion : @(0.2),
                               STKPostTypeAspiration : @(0.1),
                               STKPostTypeExperience : @(0.3),
                               STKPostTypeAchievement : @(0.2),
                               STKPostTypeInspiration : @(0.1),
                               STKPostTypePersonal : @(0.1)}];
    [self configureChartArea];
    [self configureGraphArea];
    
    [[self percentTableView] reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self percentTableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self percentTableView] setScrollEnabled:NO];
    [[self percentTableView] setBackgroundColor:[UIColor clearColor]];
    
    [[self graphView] setXLabels:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7"]];
    [[self graphView] setYLabels:@[@"0", @"10", @"20", @"30", @"40"]];
}

- (NSArray *)temporaryValues
{
    srand(time(NULL));

    return @[
             @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypePassion]},
             @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeAspiration]},
             @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeExperience]},
             @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeAchievement]},
             @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeInspiration]},
             @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypePersonal]}
    ];
}

- (NSArray *)randomNumbersToMax:(int)max count:(int)count
{
    NSMutableArray *a = [NSMutableArray array];
    for(int i = 0; i < count; i++) {
        [a addObject:@((rand() % max) / (float)max)];
    }
    return a;
}

- (void)configureGraphArea
{
    [[self graphView] setValues:[self graphValues]];
}

- (void)configureChartArea
{
    NSMutableArray *orderedColors = [NSMutableArray array];
    NSMutableArray *orderedValues = [NSMutableArray array];
    for(NSString *key in [self orderArray]) {
        [orderedColors addObject:[[self typeColors] objectForKey:key]];
        [orderedValues addObject:[[self typePercentages] objectForKey:key]];
    }
    [[self pieChartView] setColors:orderedColors];
    [[self pieChartView] setValues:orderedValues];
 
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self orderArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKGraphCell *c = [STKGraphCell cellForTableView:tableView target:self];
    
    NSString *key = [[self orderArray] objectAtIndex:[indexPath row]];
    [[c nameLabel] setText:[[self typeNames] objectForKey:key]];
    
    float percent = [[[self typePercentages] objectForKey:key] floatValue];
    UIColor *clr = [[self typeColors] objectForKey:key];
    [[c colorWell] setBackgroundColor:clr];
    
    [[c percentLabel] setText:[NSString stringWithFormat:@"%.0f%%", 100 * percent]];
    
    return c;
}


@end
