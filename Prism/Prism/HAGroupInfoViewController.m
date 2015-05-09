//
//  HAGroupInfoViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 5/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAGroupInfoViewController.h"
#import "STKGroup.h"
#import "STKUserStore.h"
#import "UIViewController+STKControllerItems.h"
#import "STKOrganization.h"
#import "STKUser.h"

@interface HAGroupInfoViewController ()

@property (nonatomic, strong) STKGroup *group;
@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) NSLayoutConstraint *textViewHeight;
@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) UIBarButtonItem *muteButton;
@property (nonatomic, getter=isMuted) BOOL muted;

@end

@implementation HAGroupInfoViewController

- (id)init
{
    self = [super init];
    if (self){
        [self configureView];
    }
    return self;
}

- (id)initWithOrganization:(STKOrganization *)organization Group:(STKGroup *)group
{
    self = [super init];
    if (self) {
        _group = group;
        _organization = organization;
        _user = [[STKUserStore store] currentUser];
        [self configureView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureView
{
    self.underlayView = [[UIView alloc] init];
    [self.underlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.underlayView];
    self.textView = [[UITextView alloc] init];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textView setScrollEnabled:NO];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    [self.textView setFont:STKFont(14)];
    [self.textView setTextColor:[UIColor HATextColor]];
    [self.textView setEditable:NO];
    if (self.group) {
        self.title = [NSString stringWithFormat:@"#%@", [self.group.name lowercaseString]];
        [self.textView setText:self.group.groupDescription];
    } else {
        self.title = @"#all";
        NSString *text = [NSString stringWithFormat:@"This group contains all members of %@.", self.organization.name];
        [self.textView setText:text];
        
    }
    [self.textView sizeToFit];
    self.textViewHeight = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.textView.frame.size.height];
    [self.underlayView addSubview:self.textView];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                              landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(back:)];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:bbi];
    self.muteButton = [[UIBarButtonItem alloc] initWithImage:nil landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(mute:)];
    [self.navigationItem setRightBarButtonItem:self.muteButton];
    [self checkMutes];
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
    [self.underlayView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];

    [self setupConstraints];
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[uv]-0-|" options:0 metrics:nil views:@{@"uv": _underlayView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_underlayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:65]];
    
    [self.underlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[tv]-16-|" options:0 metrics:nil views:@{@"tv": _textView}]];
    [self.underlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[tv]-15-|" options:0 metrics:nil views:@{@"tv": _textView}]];
    [self.underlayView addConstraint:_textViewHeight];
}

- (void)mute:(id)sender
{
    self.muted = ! [self isMuted];
    if (self.group) {
        [[STKUserStore store] muteGroup:self.group muted:self.muted completion:^(id data, NSError *error) {
            [self checkMutes];
        }];
    } else if (self.organization) {
        [[STKUserStore store] muteOrganization:self.organization muted:self.muted completion:^(id data, NSError *error) {
            [self checkMutes];
        }];
    }
}

- (void)checkMutes
{
    self.muted = NO;
    if (self.group) {
        [self.group.mutes enumerateObjectsUsingBlock:^(STKUser* obj, BOOL *stop) {
            if ([obj.uniqueID isEqualToString:self.user.uniqueID]){
                self.muted = YES;
                *stop = YES;
            }
        }];
    } else if (self.organization){
        [self.organization.mutes enumerateObjectsUsingBlock:^(STKUser* obj, BOOL *stop) {
            if ([obj.uniqueID isEqualToString:self.user.uniqueID]){
                self.muted = YES;
                *stop = YES;
            }
        }];
    }
    if ([self isMuted]) {
        [self.muteButton setImage:[UIImage imageNamed:@"btn_mute_active"]];
    } else {
        [self.muteButton setImage:[UIImage imageNamed:@"btn_mute"]];
    }
}

@end
