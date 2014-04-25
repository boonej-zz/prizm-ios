//
//  STKRequestCell.m
//  Prism
//
//  Created by Joe Conway on 1/29/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKRequestCell.h"
#import "STKTrust.h"
#import "STKUser.h"
#import "STKRelativeDateConverter.h"

@implementation STKRequestCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

- (void)populateWithTrust:(STKTrust *)i
{
    [[self dateLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[i dateCreated]]];
    [[self avatarImageView] setUrlString:[[i creator] profilePhotoPath]];
    [[self nameLabel] setText:[[i creator] name]];
    
    [[self rejectButton] setHidden:YES];
    [[self acceptButton] setHidden:YES];
    NSString *typeString = nil;
    if([i isPending]) {
        [[self rejectButton] setHidden:NO];
        [[self acceptButton] setHidden:NO];
        typeString = @"wants to enter into a Trust with you.";
    } else if([i isAccepted]) {
        typeString = [NSString stringWithFormat:@"You and %@ are now in a trust.", [[i creator] firstName]];
    } else if([i isRejected]) {
        typeString = @"trust denied.";
    }
    
    [[self typeLabel] setText:typeString];
    [[self unreadIndicatorView] setHidden:[i hasBeenViewed]];

    [[self acceptIndicator] setHidden:![i isAccepted]];
}

- (IBAction)acceptRequest:(id)sender
{
    ROUTE(sender);
}

- (IBAction)rejectRequest:(id)sender
{
    ROUTE(sender);
}

- (IBAction)profileTapped:(id)sender
{
    ROUTE(sender);
}
@end
