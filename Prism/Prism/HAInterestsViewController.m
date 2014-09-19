//
//  HAInterestsViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 9/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAInterestsViewController.h"
#import "HAHashTagView.h"
#import "STKUserStore.h"
#import "STKProcessingView.h"

static int currentTag = 0;

@interface HAInterestsViewController () <HAHashTagViewDelegate>

@property (nonatomic, weak) IBOutlet UIView * tagView;
@property (nonatomic, strong) NSArray * tagList;
@property (nonatomic, strong) NSMutableArray * tagObjects;
@property (nonatomic, strong) NSMutableArray * selectedHashTags;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation HAInterestsViewController

#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Interests";
    UIImage *backgroundImage = [UIImage imageNamed:@"img_background"];
    self.tagList = @[@"fitness", @"beauty", @"sports", @"technology", @"business", @"design", @"photography", @"style", @"politics", @"arts", @"food", @"music", @"movies", @"gaming", @"auto", @"science", @"travel", @"medicine", @"legal", @"hunting", @"fishing"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backgroundView setFrame:self.view.bounds];
    [self.view insertSubview:backgroundView atIndex:0];
    self.tagObjects = [NSMutableArray array];
    self.selectedHashTags = [NSMutableArray array];
    [self createTags];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self animateNextTag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)doneButtonTapped:(id)sender
{
    __block NSMutableArray *hashtags = [NSMutableArray array];
    [self.selectedHashTags enumerateObjectsUsingBlock:^(HAHashTagView *ht, NSUInteger idx, BOOL *stop) {
        [hashtags addObject:ht.text];
    }];
    [STKProcessingView present];
    [[STKUserStore store] updateInterests:hashtags forUser:self.user completion:^(STKUser *u, NSError *err) {
        [STKProcessingView dismiss];
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark Hashtag Methods
- (void)createTags
{
    [self.tagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HAHashTagView *hv = [self createViewForTag:obj];
        [self.tagObjects addObject:hv];
        [self.tagView addSubview:hv];
    }];
}

- (HAHashTagView *)createViewForTag:(NSString *)tag
{
    HAHashTagView *hv = [[HAHashTagView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [hv setText:tag];
    [hv setDelegate:self];
    [hv setAlpha:0.0f];
    return hv;
}

- (void)animateNextTag
{
    HAHashTagView *hv = [self.tagObjects objectAtIndex:[self nextTag]];
    [hv presentAndDismiss];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateNextTag];
    });
}

- (int)nextTag
{
    if (currentTag < self.tagObjects.count) {
        return currentTag++;
    } else {
        currentTag = 0;
        return currentTag;
    }
}

#pragma mark Hashtag View Delegate

- (void)hashTagTapped:(HAHashTagView *)ht
{
    if ([ht isSelected]) {
        if ([self.tagObjects containsObject:ht]) {
            [self.tagObjects removeObject:ht];
            [self.selectedHashTags addObject:ht];
        }
    } else {
        if ([self.selectedHashTags containsObject:ht]) {
            [self.selectedHashTags removeObject:ht];
            [self.tagObjects addObject:ht];
        }
    }
}

@end
