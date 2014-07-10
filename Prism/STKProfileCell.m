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
    [[self scrollView] setScrollsToTop:NO];
    
    [[self nameLabel] setFont:STKFont(18)];
    [[self locationLabel] setFont:STKFont(12)];
    [[self blurbLabel] setFont:STKFont(14)];
    [[self luminaryInfoLabel] setFont:STKFont(12)];
    [[self leftNameLabel] setFont:STKFont(14)];
    [[self centerNameLabel] setFont:STKFont(14)];
    [[self rightNameLabel] setFont:STKFont(14)];
    [[self luminaryLabel] setFont:STKFont(18)];
    
    [[self blurbLabel] setTextColor:[UIColor whiteColor]];
    [[self leftNameLabel] setTextColor:[UIColor whiteColor]];
    [[self leftTitleLabel] setTextColor:[UIColor whiteColor]];
    [[self centerNameLabel] setTextColor:[UIColor whiteColor]];
    [[self centerTitleLabel] setTextColor:[UIColor whiteColor]];
    [[self rightNameLabel] setTextColor:[UIColor whiteColor]];
    [[self rightTitleLabel] setTextColor:[UIColor whiteColor]];
    [[self luminaryLabel] setTextColor:[UIColor whiteColor]];
    [[self moreLuminariesButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:[[self profileGradient] bounds]];
    [gradient setColors:@[(id)[[UIColor colorWithWhite:0 alpha:0.0] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.6] CGColor]]];
//    [gradient setLocations:@[@(0.4), @(1)]];
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
    float topOpacity = 0;
    if(offset < 320.0) {
        // 0 -> 0
        // 160 -> 0.3
        // 320 -> 0.6
        topOpacity = (offset / 320.0) * 0.6;
    } else {
        topOpacity = 0.6;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [[self gradientLayer] setColors:@[(id)[[UIColor colorWithWhite:0 alpha:topOpacity] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.6] CGColor]]];
    [CATransaction commit];
    
    
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

- (IBAction)pageLeft:(id)sender
{
    float offset = [[self scrollView] contentOffset].x;
    CGSize scrollViewSize = [[self scrollView] bounds].size;

    offset -= 320;
    
    [[self scrollView] scrollRectToVisible:CGRectMake(offset, 0, scrollViewSize.width, scrollViewSize.height) animated:YES];
}

- (IBAction)pageRight:(id)sender
{
    float offset = [[self scrollView] contentOffset].x;
    CGSize scrollViewSize = [[self scrollView] bounds].size;

    offset += 320;
    
    [[self scrollView] scrollRectToVisible:CGRectMake(offset, 0, scrollViewSize.width, scrollViewSize.height) animated:YES];
}

@end
