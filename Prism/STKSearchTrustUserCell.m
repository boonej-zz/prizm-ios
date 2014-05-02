//
//  STKSearchTrustUserCell.m
//  Prism
//
//  Created by DJ HAYDEN on 5/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSearchTrustUserCell.h"

@implementation STKSearchTrustUserCell

- (void)populateWithUser:(STKUser *)user
{
    [[self avatarView] setUrlString:[user profilePhotoPath]];
    [[self nameLabel] setText:[(NSString *)[user name] capitalizedString]];
}

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

@end
