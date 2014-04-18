//
//  STKLuminariesCell.m
//  Prism
//
//  Created by Joe Conway on 4/15/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKLuminariesCell.h"
#import "STKAvatarView.h"
#import "STKUser.h"
@implementation STKLuminariesCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

- (void)setUsers:(NSArray *)users
{
    [[self leftAvatarView] setUrlString:nil];
    [[self leftNameLabel] setText:@""];
    [[self leftTitleLabel] setText:@""];

    [[self centerAvatarView] setUrlString:nil];
    [[self centerNameLabel] setText:@""];
    [[self centerTitleLabel] setText:@""];
    
    [[self rightNameLabel] setText:@""];
    [[self rightAvatarView] setUrlString:nil];
    [[self rightTitleLabel] setText:@""];
    
    if([users count] > 0) {
        STKUser *u = [users objectAtIndex:0];
        [[self leftAvatarView] setUrlString:[u profilePhotoPath]];
        [[self leftNameLabel] setText:[u name]];
    }
    
    if([users count] > 1) {
        STKUser *u = [users objectAtIndex:1];
        [[self centerAvatarView] setUrlString:[u profilePhotoPath]];
        [[self centerNameLabel] setText:[u name]];
    }

    if([users count] > 2) {
        STKUser *u = [users objectAtIndex:2];
        [[self rightAvatarView] setUrlString:[u profilePhotoPath]];
        [[self rightNameLabel] setText:[u name]];
    }

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
