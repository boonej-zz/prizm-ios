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
#import "STKNavigationButton.h"

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
@property (weak, nonatomic) IBOutlet UILabel *lifetimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightDateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lifetimeActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *graphActivityIndicator;

@property (nonatomic, strong) NSArray *orderArray;
@property (nonatomic, strong) NSDictionary *typePercentages;
@property (nonatomic, strong) NSDictionary *typeColors;
@property (nonatomic, strong) NSDictionary *typeNames;
@property (nonatomic, strong) NSMutableDictionary *graphValues;
@property (nonatomic, strong) NSDictionary *typeHashTags;

@property (nonatomic, strong) NSString *currentFilter;

@end

@implementation STKGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Graph"];

//        STKNavigationButton *view = [[STKNavigationButton alloc] init];
//        [view addTarget:self action:@selector(showInsights:) forControlEvents:UIControlEventTouchUpInside];
//        [view setImage:[UIImage imageNamed:@"insight"]];
//        [view setSelectedImage:[UIImage imageNamed:@"insight"]];
//        [view setOffset:11];
//        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
//        [[self navigationItem] setRightBarButtonItem:bbi];
        
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
        
    
    }
    return self;
}

- (void)showInsights:(id)sender
{
    
}

- (IBAction)dateBarDidChange:(id)sender
{
    [self updateGraph];
}

- (void)updateGraph
{
    int askingWeek = [[self dateBar] lastWeekInYear];
    int askingYear = [[self dateBar] year];
    [[self graphActivityIndicator] startAnimating];
    [[STKUserStore store] fetchGraphDataForWeek:askingWeek - 7
                                         inYear:askingYear
                              previousWeekCount:7
                                     completion:^(NSDictionary *weeks, NSError *err) {
                                         if(askingWeek == [[self dateBar] lastWeekInYear] && askingYear == [[self dateBar] year]) {
                                             [[self graphActivityIndicator] stopAnimating];
                                         }
                                         [self addWeeklyEntries:weeks];
                                         [self configureGraphArea];
                                     }];
    
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
    _currentFilter = currentFilter;
    
    [self configureGraphArea];
    [self configureChartArea];
    
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
    
    [[self lifetimeActivityIndicator] startAnimating];
    [[STKUserStore store] fetchLifetimeGraphDataWithCompletion:^(NSDictionary *vals, NSError *err) {
        [[self lifetimeActivityIndicator] stopAnimating];
        if(!err) {
            int total = 0;
            for(NSString *key in vals) {
                if(![key isEqualToString:STKPostTypeAccolade]) {
                    NSNumber *v = [vals objectForKey:key];
                    total += [v intValue];
                }
            }
            
            NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
            for(NSString *key in vals) {
                [results setObject:@([[vals objectForKey:key] floatValue] / (float)total) forKey:key];
            }
            [self setTypePercentages:results];
        }
        [self configureChartArea];
        [[self percentTableView] reloadData];
    }];
    
    [self updateGraph];
    
    [[STKUserStore store] fetchHashtagsForPostTypesWithCompletion:^(NSDictionary *hashTags, NSError *err) {
        if(!err) {
            [self setTypeHashTags:hashTags];
        }
        [[self percentTableView] reloadData];
    }];
    
    [self configureChartArea];

    [self configureGraphArea];
    [[self percentTableView] reloadData];

}

- (void)addWeeklyEntries:(NSDictionary *)weeklyEntries
{
    if(![self graphValues]) {
        _graphValues = [[NSMutableDictionary alloc] init];
    }
    
    for(NSString *yearKey in weeklyEntries) {
        NSMutableDictionary *existingYearValues = [[self graphValues] objectForKey:yearKey];
        if(!existingYearValues) {
            existingYearValues = [[NSMutableDictionary alloc] init];
            [[self graphValues] setObject:existingYearValues forKey:yearKey];
        }
        
        NSDictionary *weekValues = [weeklyEntries objectForKey:yearKey];
        for(NSString *weekKey in weekValues) {
            [existingYearValues setObject:[weekValues objectForKey:weekKey] forKey:weekKey];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self lifetimeLabel] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    [[[self lifetimeLabel] layer] setCornerRadius:2];
    [[self lifetimeLabel] setClipsToBounds:YES];
    
    [[self percentTableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self percentTableView] setScrollEnabled:NO];
    [[self percentTableView] setBackgroundColor:[UIColor clearColor]];
    
    [[self graphView] setXLabels:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7"]];
    [[self graphView] setYLabels:@[@"", @"25%", @"50%", @"75%", @"100%"]];
}


- (NSArray *)valuesForType:(NSString *)type weekEnd:(int)count yearEnd:(int)year
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for(int i = 0; i < 7; i++) {
        
        NSDictionary *yearDict = [[self graphValues] objectForKey:[NSString stringWithFormat:@"%d", year]];
        NSDictionary *weekDict = [yearDict objectForKey:[NSString stringWithFormat:@"%d", count]];
        NSNumber *val = [weekDict objectForKey:type];
        if(!val) {
            [values insertObject:@(0) atIndex:0];
        } else {
            [values insertObject:val atIndex:0];
        }
        
        count --;
        if(count == 0) {
            year --;
            count = 52;
        }
    }
    return values;
}

- (void)convertGraphValuesToPercentages:(NSArray *)values
{
    NSMutableDictionary *totals = [NSMutableDictionary dictionary];
    for(NSDictionary *v in values) {
        NSArray *ys = [v objectForKey:@"y"];
        for(int i = 0; i < [ys count]; i++) {
            int count = [[ys objectAtIndex:i] intValue];
            
            NSNumber *currentCount = [totals objectForKey:@(i)];
            if(!currentCount) {
                [totals setObject:@(count) forKey:@(i)];
            } else {
                [totals setObject:@(count + [currentCount intValue]) forKey:@(i)];
            }
        }
    }
    
    for(NSMutableDictionary *v in values) {
        NSMutableArray *a = [[NSMutableArray alloc] init];
        NSArray *ys = [v objectForKey:@"y"];
        for(int i = 0; i < [ys count]; i++) {
            float total = [[totals objectForKey:@(i)] floatValue];
            if(total == 0.0) {
                [a addObject:@(0)];
            } else {
                int count = [[ys objectAtIndex:i] intValue];
                [a addObject:@((float)count / total)];
            }
        }
        [v setObject:a forKey:@"y"];
    }
}

- (void)configureGraphArea
{
    int weekEnd = [[self dateBar] lastWeekInYear];
    int yearEnd = [[self dateBar] year];
    
    NSMutableArray *orderedValues = [NSMutableArray array];
    NSMutableDictionary *filteredValue = nil;
    for(NSString *key in [[self orderArray] reverseObjectEnumerator]) {
        NSMutableDictionary *data = [@{@"y" : [self valuesForType:key weekEnd:weekEnd yearEnd:yearEnd], @"color" : [[self typeColors] objectForKey:key]} mutableCopy];
        [orderedValues addObject:data];
        if([[self currentFilter] isEqualToString:key]) {
            filteredValue = data;
        }
    }
    
    [self convertGraphValuesToPercentages:orderedValues];
    
    if(filteredValue) {
        orderedValues = [@[filteredValue] mutableCopy];
    }
    
    [[self graphView] setValues:orderedValues];
    
    NSCalendar *greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *dc = [[NSDateComponents alloc] init];
    [dc setWeekOfYear:weekEnd];
    [dc setYearForWeekOfYear:yearEnd];
    [dc setWeekday:7];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M-d-yyyy"];
    
    [[self rightDateLabel] setText:[df stringFromDate:[greg dateFromComponents:dc]]];

    [dc setWeekOfYear:[dc weekOfYear] - 7];
    [dc setWeekday:1];
    [[self leftDateLabel] setText:[df stringFromDate:[greg dateFromComponents:dc]]];
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
            
            NSNumber *percent = [[self typePercentages] objectForKey:key];
            if(!percent)
                percent = @0;
            [orderedValues addObject:percent];
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
        NSArray *hashTags = [[self typeHashTags] objectForKey:[self currentFilter]];
        if([hashTags count] > 5) {
            return 1 + 5;
        } else {
            return 1 + [hashTags count];
        }
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
                [c setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            NSArray *hashTags = [[self typeHashTags] objectForKey:[self currentFilter]];
            NSDictionary *hashTagRecord = [hashTags objectAtIndex:row - 1];
            
            [[c textLabel] setText:[NSString stringWithFormat:@"#%@", [hashTagRecord objectForKey:@"hash_tag"]]];
            
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
