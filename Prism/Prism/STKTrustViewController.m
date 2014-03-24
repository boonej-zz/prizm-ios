//
//  STKTrustViewController.m
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTrustViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKTrustView.h"
#import "STKCountView.h"
#import "STKUserStore.h"
#import "STKImageStore.h"
#import "STKUser.h"
#import "STKRenderServer.h"
#import "STKUserListViewController.h"

@interface STKTrustViewController () <STKTrustViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *selectedNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet STKTrustView *trustView;
@property (weak, nonatomic) IBOutlet STKCountView *countView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *underlayView;
@property (nonatomic, strong) NSArray *trusts;

- (IBAction)showList:(id)sender;
- (IBAction)sendEmail:(id)sender;

@end

@implementation STKTrustViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setLeftBarButtonItem:[self menuBarButtonItem]];
        [[self navigationItem] setTitle:@"Trust"];
        [[self navigationItem] setRightBarButtonItem:[self postBarButtonItem]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_trust"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_trust_selected"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self countView] setCircleTitles:@[@"Likes", @"Comments", @"Posts"]];
    [[self countView] setCircleValues:@[@"0", @"0", @"0"]];
    [[self trustView] setDelegate:self];
}

- (void)trustView:(STKTrustView *)tv didSelectCircleAtIndex:(int)idx
{
    [self selectUserAtIndex:idx - 1];
}

- (void)selectUserAtIndex:(int)idx
{
    if(idx >= 0 && idx < [[self trusts] count]) {
        STKUser *u = [[[self trusts] valueForKey:@"otherUser"] objectAtIndex:idx];
        
        [[self selectedNameLabel] setText:[u name]];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self trustView] setUser:[[STKUserStore store] currentUser]];
    
    if(![[self backgroundImageView] image]) {
        [[STKImageStore store] fetchImageForURLString:[[[STKUserStore store] currentUser] profilePhotoPath] completion:^(UIImage *img) {
            UIGraphicsBeginImageContext(CGSizeMake(80, 80));
            [img drawInRect:CGRectMake(0, 0, 80, 80)];
            UIImage *blurredImage = [[STKRenderServer renderServer] blurredImageWithImage:UIGraphicsGetImageFromCurrentImageContext() affineClamp:YES];
            [[self backgroundImageView] setImage:blurredImage];
            UIGraphicsEndImageContext();
        }];
    }
    
    [[STKUserStore store] fetchTrustsForUser:[[STKUserStore store] currentUser] completion:^(NSArray *trusts, NSError *err) {
        [self setTrusts:trusts];
        [[self trustView] setUsers:[[self trusts] valueForKey:@"otherUser"]];
        [self configureInterface];
    }];
    
}

- (void)configureInterface
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showList:(id)sender
{

    
}

- (IBAction)sendEmail:(id)sender
{
    
}
@end
