//
//  HASingleMessageImageController.m
//  Prizm
//
//  Created by Jonathan Boone on 5/20/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HASingleMessageImageController.h"
#import "STKMessage.h"
#import "STKUser.h"
#import "STKImageStore.h"

@interface HASingleMessageImageController ()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) STKMessage *message;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@end

@implementation HASingleMessageImageController

- (id)init
{
    self = [super init];
    if (self){
        [self configureViews];
        [self setupConstraints];
    }
    return self;
}

- (id)initWithMessage:(STKMessage *)message
{
    self = [super init];
    if (self){
        self.message = message;
        [self configureViews];
        [self setupConstraints];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewDidDisappear:animated];
}

- (void)configureViews
{
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.imageView setUserInteractionEnabled:YES];
    [self.view addSubview:self.imageView];
    self.closeButton = [[UIButton alloc] init];
    [self.closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.closeButton setEnabled:YES];
    [self.closeButton setBackgroundColor:[UIColor clearColor]];
    [self.closeButton setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPress:)];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    [self.view addGestureRecognizer:self.longPressGesture];
    [self.view addSubview:self.closeButton];
    [self.view bringSubviewToFront:self.closeButton];
}

- (void)setupConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[iv]-44-|" options:0 metrics:nil views:@{@"iv": self.imageView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[iv]-0-|" options:0 metrics:nil views:@{@"iv": self.imageView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:24.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:24.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:18.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.f constant:-16.f]];
}

- (void)loadContent
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    
    [self.navigationController setNavigationBarHidden:YES];
//    NSLog(@"%@", self.message.imageURL);
    if (self.message) {
        [[STKImageStore store] fetchImageForURLString:self.message.imageURL preferredSize:STKImageStoreThumbnailLarge completion:^(UIImage *img) {
            if (img.size.width < self.imageView.bounds.size.width && img.size.height < self.imageView.bounds.size.height){
                [self.imageView setContentMode:UIViewContentModeCenter];
            } else {
                [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
            [self.imageView setImage:img];
        }];
    }
}

- (void)close:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageLongPress:(id)sender
{
    UIActivityViewController *av = [[UIActivityViewController alloc] initWithActivityItems:@[self.imageView.image] applicationActivities:nil];
    [self presentViewController:av animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
