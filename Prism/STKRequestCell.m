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
    
}

- (void)layoutContent
{
    
}

- (void)populateWithTrust:(STKTrust *)i
{
    [[self dateLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[i dateCreated]]];
    [[self avatarImageView] setUrlString:[[i otherUser] profilePhotoPath]];
    [[self nameLabel] setText:[[i otherUser] name]];
    
    [[self rejectButton] setHidden:YES];
    [[self acceptButton] setHidden:YES];
    NSString *typeString = nil;
    if([i isPending]) {
        [[self rejectButton] setHidden:NO];
        [[self acceptButton] setHidden:NO];
        typeString = @"requested to join your trust.";
    } else if([i isAccepted]) {
        typeString = @"is now in your trust.";
    } else if([i isRejected]) {
        typeString = @"trust rejected.";
    }
    
    [[self typeLabel] setText:typeString];

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
