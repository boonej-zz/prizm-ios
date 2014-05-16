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

@property (weak, nonatomic) IBOutlet UIButton *aspirationButton;
@property (weak, nonatomic) IBOutlet UIButton *passionButton;
@property (weak, nonatomic) IBOutlet UIButton *experienceButton;
@property (weak, nonatomic) IBOutlet UIButton *achievementButton;
@property (weak, nonatomic) IBOutlet UIButton *inspirationButton;
@property (weak, nonatomic) IBOutlet UIButton *personalButton;

@property (weak, nonatomic) IBOutlet STKGraphView *graphView;
@property (weak, nonatomic) IBOutlet STKPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet UITableView *percentTableView;
@property (weak, nonatomic) IBOutlet STKDateBar *dateBar;
@property (weak, nonatomic) IBOutlet UIView *underlayView;

@property (nonatomic, strong) NSArray *orderArray;
@property (nonatomic, strong) NSDictionary *typePercentages;
@property (nonatomic, strong) NSDictionary *typeColors;
@property (nonatomic, strong) NSDictionary *typeNames;
@property (nonatomic, strong) NSDictionary *graphValues;

@property (nonatomic, strong) NSArray *filteredHashTags;
@property (nonatomic, strong) NSString *currentFilter;

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
        
        [self setTypeColors:@{STKPostTypePassion : [UIColor colorWithRed:242./255.0 green:66./255.0 blue:0 alpha:1],
                              STKPostTypeAspiration : [UIColor colorWithRed:58./255.0 green:164./255.0 blue:246./255.0 alpha:1],
                              STKPostTypeExperience : [UIColor colorWithRed:103./255.0 green:189./255.0 blue:9./255.0 alpha:1],
                              STKPostTypeAchievement : [UIColor colorWithRed:254./255.0 green:121./255.0 blue:0 alpha:1],
                              STKPostTypeInspiration : [UIColor colorWithRed:217./255.0 green:186./255.0 blue:100./255.0 alpha:1],
                              STKPostTypePersonal : [UIColor colorWithRed:185./255.0 green:194./255.0 blue:213./255.0 alpha:1]
                              }];
        [self setOrderArray:@[STKPostTypeAspiration, STKPostTypePassion, STKPostTypeExperience, STKPostTypeAchievement, STKPostTypeInspiration, STKPostTypePersonal]];
    
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

- (IBAction)dateBarDidChange:(id)sender
{
    [self setGraphValues:[self temporaryValues]];
    [self configureGraphArea];

}

- (IBAction)toggleItem:(id)sender
{
    if([sender isSelected]) {
        [sender setSelected:NO];
        [self setCurrentFilter:nil];
        return;
    }
    [[self aspirationButton] setSelected:NO];
    [[self passionButton] setSelected:NO];
    [[self experienceButton] setSelected:NO];
    [[self achievementButton] setSelected:NO];
    [[self inspirationButton] setSelected:NO];
    [[self personalButton] setSelected:NO];
    
    [sender setSelected:YES];
    
    if(sender == [self aspirationButton]) {
        [self setCurrentFilter:STKPostTypeAspiration];
    } else if(sender == [self passionButton]) {
        [self setCurrentFilter:STKPostTypePassion];
    } else if(sender == [self experienceButton]) {
        [self setCurrentFilter:STKPostTypeExperience];
    } else if(sender == [self achievementButton]) {
        [self setCurrentFilter:STKPostTypeAchievement];
    } else if(sender == [self inspirationButton]) {
        [self setCurrentFilter:STKPostTypeInspiration];
    } else if(sender == [self personalButton]) {
        [self setCurrentFilter:STKPostTypePersonal];
    }
}


- (void)setCurrentFilter:(NSString *)currentFilter
{
    [self setFilteredHashTags:nil];
    
    _currentFilter = currentFilter;
    
    [self configureGraphArea];
    [self configureChartArea];
    
    [[STKUserStore store] fetchHashtagsForPostType:currentFilter completion:^(NSArray *hashTags, NSError *err) {

        [self setFilteredHashTags:hashTags];
        
        [self setFilteredHashTags:@[@"foobar", @"boom", @"bar", @"college"]];
        
        [[self percentTableView] reloadData];
        
    }];
    [[self percentTableView] reloadData];
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
    [[self graphView] setYLabels:@[@"", @"25%", @"50%", @"75%", @"100%"]];
}

- (NSDictionary *)temporaryValues
{
    srand(time(NULL));

    return @{
             STKPostTypePersonal : @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypePersonal]},
             STKPostTypeInspiration : @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeInspiration]},
             STKPostTypeAchievement : @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeAchievement]},
             STKPostTypeExperience : @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeExperience]},
             STKPostTypePassion : @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypePassion]},
             STKPostTypeAspiration : @{@"y" : [self randomNumbersToMax:40 count:7], @"color" : [[self typeColors] objectForKey:STKPostTypeAspiration]}

    };
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
    NSMutableArray *orderedValues = [NSMutableArray array];
    if([self currentFilter]) {
        [orderedValues addObject:[[self graphValues] objectForKey:[self currentFilter]]];
    } else {
        for(NSString *key in [[self orderArray] reverseObjectEnumerator]) {
            [orderedValues addObject:[[self graphValues] objectForKey:key]];
        }
    }
    [[self graphView] setValues:orderedValues];
}

- (void)configureChartArea
{
    NSMutableArray *orderedColors = [NSMutableArray array];
    NSMutableArray *orderedValues = [NSMutableArray array];
    if([self currentFilter]) {
        [orderedColors addObject:[[self typeColors] objectForKey:[self currentFilter]]];
        float v = [[[self typePercentages] objectForKey:[self currentFilter]] floatValue];
        [orderedValues addObject:@(v)];
        
        [orderedValues addObject:@(1.0 - v)];
        [orderedColors addObject:[UIColor colorWithRed:.29 green:.35 blue:.54 alpha:1]];
    } else {
        for(NSString *key in [self orderArray]) {
            [orderedColors addObject:[[self typeColors] objectForKey:key]];
            [orderedValues addObject:[[self typePercentages] objectForKey:key]];
        }
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
    if([self currentFilter]) {
        return 1 + [[self filteredHashTags] count];
    }
    return [[self orderArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if([self currentFilter]) {
        if([indexPath row] > 0) {
            UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
                [[c textLabel] setFont:STKFont(12)];
                [[c textLabel] setTextColor:[UIColor whiteColor]];
            }
            
            [[c textLabel] setText:[NSString stringWithFormat:@"#%@", [[self filteredHashTags] objectAtIndex:row - 1]]];
            
            return c;
        } else {
            row = [[self orderArray] indexOfObject:[self currentFilter]];
        }
    }
    
    STKGraphCell *c = [STKGraphCell cellForTableView:tableView target:self];
    
    NSString *key = [[self orderArray] objectAtIndex:row];
    [[c nameLabel] setText:[[self typeNames] objectForKey:key]];
    
    float percent = [[[self typePercentages] objectForKey:key] floatValue];
    UIColor *clr = [[self typeColors] objectForKey:key];
    [[c colorWell] setBackgroundColor:clr];
    
    [[c percentLabel] setText:[NSString stringWithFormat:@"%.0f%%", 100 * percent]];
    
    return c;
}


@end
