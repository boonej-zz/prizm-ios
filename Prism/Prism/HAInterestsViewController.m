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
@property (nonatomic, weak) IBOutlet UIView * overlayView;
@property (nonatomic, strong) UIBarButtonItem * doneButton;
@property (nonatomic, strong) NSMutableDictionary *tagPositions;

- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)overlayCloseTapped:(id)sender;

@end

@implementation HAInterestsViewController

#pragma mark View Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setStandalone:NO];
    }
    return self;
}

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
    self.tagPositions = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view from its nib.
    if ([self isStandalone]){
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                                  landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(back:)];
        [self.navigationItem setLeftBarButtonItem:bbi];
    }
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    [self.doneButton setEnabled:NO];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : STKTextColor,
                                                                      NSFontAttributeName : STKFont(22)}];
    [self.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                              NSFontAttributeName : STKFont(16)} forState:UIControlStateNormal];
    [self.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor clearColor],
                                              NSFontAttributeName : STKFont(16)} forState:UIControlStateDisabled];
    
    [self.navigationItem setRightBarButtonItem:self.doneButton];
    
    self.title = @"Interests";
    UIImage *backgroundImage = [UIImage imageNamed:@"img_background"];
    self.tagList = @[@"fitness", @"beauty", @"sports", @"technology", @"business", @"design", @"photography", @"style", @"politics", @"arts", @"food", @"music", @"movies", @"gaming", @"auto", @"science", @"travel", @"medicine", @"legal", @"hunting", @"fishing"];
//    self.tagList = [[NSUserDefaults standardUserDefaults] objectForKey:HAUserStoreInterestsKey];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backgroundView setFrame:self.view.bounds];
    [self.view insertSubview:backgroundView atIndex:0];
    self.tagObjects = [NSMutableArray array];
    self.selectedHashTags = [NSMutableArray array];
    [self createTags];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
        if ([self isStandalone]){
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)overlayCloseTapped:(id)sender
{
    [self.overlayView setHidden:YES];
    [self animateNextTag];
}

- (void)hideOverlayView
{
    [self.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor lightTextColor],
                                              NSFontAttributeName : STKFont(16)} forState:UIControlStateDisabled];
    [self.overlayView setHidden:YES];
}

#pragma mark Hashtag Methods
- (void)createTags
{
    [self.tagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSString *tag = [obj objectForKey:@"name"];
        NSString *tag = obj;
        HAHashTagView *hv = [self createViewForTag:tag];
        [self.tagObjects addObject:hv];
        [self.tagView addSubview:hv];
        [self.tagPositions setObject:hv forKey:tag];
        [hv setSisterTags:self.tagPositions];
    }];
    if (self.user.interests && ![self.user.interests isEqualToString:@""]){
        NSArray *interests = [self.user.interests componentsSeparatedByString:@","];
        [interests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           NSArray *foundTags = [self.tagObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(HAHashTagView *evaluatedObject, NSDictionary *bindings) {
               if ([evaluatedObject.text isEqualToString:obj]) {
                   return YES;
               } else {
                   return NO;
               }
               
           }]];
            if (foundTags.count > 0) {
                [foundTags enumerateObjectsUsingBlock:^(HAHashTagView *obj, NSUInteger idx, BOOL *stop) {
                    [self.tagObjects removeObject:obj];
                    [self.selectedHashTags addObject:obj];
                    [obj markSelected];
                }];
            }
        }];
        [self hideOverlayView];
        
        [self animateNextTag];
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    [self.doneButton setEnabled:(self.selectedHashTags.count > 2)];
}

@end
