//
//  STKSearchTrustCell.m
//  Prism
//
//  Created by Jesse Stevens Black on 6/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSearchTrustCell.h"

@implementation STKSearchTrustCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
}

- (void)layoutContent
{
    
}

- (IBAction)toggleTrust:(id)sender
{
    ROUTE(sender);
}

@end
