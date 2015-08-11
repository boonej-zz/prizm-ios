//
//  UISurveyDoneViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/7/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "UISurveyDoneViewController.h"
#import "STKSurvey.h"
#import "UIViewController+STKControllerItems.h"

@interface UISurveyDoneViewController ()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *bigCloseButton;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation UISurveyDoneViewController

- (id)init
{
    self = [super init];
    if (self){
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
    self.title = @"Survey";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Configuration
- (void)setupViews
{
    self.closeButton = [[UIButton alloc] init];
    [self.closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.closeButton setTitle:@"" forState:UIControlStateNormal];
    [self.closeButton setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    
    
    self.textView = [[UITextView alloc] init];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textView setFont:STKFont(22)];
    [self.textView setTextColor:[UIColor colorWithRed:53.f/255.f green:53.f/255.f blue:57.f/255.f alpha:1.f]];
    [self.textView setBackgroundColor:[UIColor colorWithRed:247.f/255.f green:247.f/255.f blue:247.f/255.f alpha:1.f]];
    [self.textView setEditable:NO];
    [self.textView setTextAlignment:NSTextAlignmentCenter];
    [self.textView setSelectable:NO];
    [self.textView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonTapped:)];
    [self.textView addGestureRecognizer:tapRecognizer];

    
    [self.view addSubview:self.textView];

    [self addBackgroundImage];
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-81-[cb(==24)]-8-[tv(>=256)]-(<=200)-|" options:0 metrics:nil views:@{@"cb": self.closeButton, @"tv": self.textView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[tv]-18-|" options:0 metrics:nil views:@{@"tv": self.textView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeRight multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.closeButton attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];

}

- (void)setSurvey:(STKSurvey *)survey
{
    _survey = survey;
    NSString *positionSuffix = @"";
    if (survey.rank) {
        switch ([survey.rank longValue]) {
            case 1:
                positionSuffix = @"st";
                break;
            case 2:
                positionSuffix = @"nd";
                break;
            case 3:
                positionSuffix = @"rd";
                break;
            default:
                positionSuffix = @"th";
                break;
        }
    }
    NSString *textString = [NSString stringWithFormat:@"Thank You!\n\nYou are the %ld%@ person \n and it took you %@ \n to complete the survey", survey.rank.longValue, positionSuffix, survey.duration];
    [self.textView setText:textString];
}

#pragma mark Actors

- (void)closeButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
