//
//  STKProfileCell.m
//  Prism
//
//  Created by Joe Conway on 12/27/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKProfileCell.h"
#import "STKUser.h"

@interface STKProfileCell () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *luminaryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *luminaryViewWidthLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *profileGradient;


@property (weak, nonatomic) IBOutlet UILabel *luminaryLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreLuminariesButton;

@property (nonatomic, weak) CAGradientLayer *gradientLayer;

@end

@implementation STKProfileCell

- (void)cellDidLoad
{
    [[self scrollView] setDelegate:self];
    
    [[self nameLabel] setFont:STKFont(18)];
    [[self locationLabel] setFont:STKFont(12)];
    [[self blurbLabel] setFont:STKFont(18)];
    [[self luminaryInfoLabel] setFont:STKFont(12)];
    [[self leftNameLabel] setFont:STKFont(18)];
    [[self centerNameLabel] setFont:STKFont(18)];
    [[self rightNameLabel] setFont:STKFont(18)];
    [[self luminaryLabel] setFont:STKFont(18)];
    
    [[self leftNameLabel] setTextColor:STKTextColor];
    [[self leftTitleLabel] setTextColor:STKTextColor];
    [[self centerNameLabel] setTextColor:STKTextColor];
    [[self centerTitleLabel] setTextColor:STKTextColor];
    [[self rightNameLabel] setTextColor:STKTextColor];
    [[self rightTitleLabel] setTextColor:STKTextColor];
    [[self luminaryLabel] setTextColor:STKTextColor];
    [[self moreLuminariesButton] setTitleColor:STKTextColor forState:UIControlStateNormal];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:[[self profileGradient] bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.3] CGColor], nil]];
    [gradient setLocations:@[@(0.4), @(1)]];
    [[[self profileGradient] layer] insertSublayer:gradient atIndex:0];
    [self setGradientLayer:gradient];
}

- (void)layoutContent
{
    
}

- (void)setType:(STKProfileCellType)type
{
    _type = type;

    if (type == STKProfileCellTypeInstitution) {
        [[self luminaryViewWidthLayoutConstraint] setConstant:320];
        [[self pageControl] setNumberOfPages:3];
    } else {
        [[self luminaryViewWidthLayoutConstraint] setConstant:0];
        [[self pageControl] setNumberOfPages:2];
    }
}

- (void)setLuminaries:(NSArray *)luminaries
{
    [[self moreLuminariesButton] setHidden:YES];
    
    [[self leftAvatarView] setUrlString:nil];
    [[self leftNameLabel] setText:@""];
    [[self leftTitleLabel] setText:@""];
    
    [[self centerAvatarView] setUrlString:nil];
    [[self centerNameLabel] setText:@""];
    [[self centerTitleLabel] setText:@""];
    
    [[self rightNameLabel] setText:@""];
    [[self rightAvatarView] setUrlString:nil];
    [[self rightTitleLabel] setText:@""];
    
    if([luminaries count] > 0) {
        STKUser *u = [luminaries objectAtIndex:0];
        [[self leftAvatarView] setUrlString:[u profilePhotoPath]];
        [[self leftNameLabel] setText:[u name]];
    }
    
    if([luminaries count] > 1) {
        STKUser *u = [luminaries objectAtIndex:1];
        [[self centerAvatarView] setUrlString:[u profilePhotoPath]];
        [[self centerNameLabel] setText:[u name]];
    }
    
    if([luminaries count] > 2) {
        STKUser *u = [luminaries objectAtIndex:2];
        [[self rightAvatarView] setUrlString:[u profilePhotoPath]];
        [[self rightNameLabel] setText:[u name]];
    }

    if ([luminaries count] > 3) {
        [[self moreLuminariesButton] setHidden:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offset = [scrollView contentOffset].x;
    if (offset <= 320) {
        [[self gradientLayer] setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:offset/320*0.5] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.3+offset/320*0.2] CGColor], nil]];
        [[self gradientLayer] setLocations:@[@((320-offset)/320*0.4), @(1)]];
    }
    
    if (offset > 480) {
        [[self pageControl] setCurrentPage:2];
    } else if (offset < 160) {
        [[self pageControl] setCurrentPage:0];
    } else {
        [[self pageControl] setCurrentPage:1];
    }
}

- (IBAction)websiteTapped:(id)sender
{
    ROUTE(sender);
}

- (IBAction)showMoreLuminariesTapped:(id)sender
{
    ROUTE(sender);
}

- (IBAction)leftLuminaryTapped:(id)sender
{
    ROUTE(sender);
}
- (IBAction)centerLuminaryTapped:(id)sender
{
    ROUTE(sender);
}
- (IBAction)rightLuminaryTapped:(id)sender
{
    ROUTE(sender);
}

@end
