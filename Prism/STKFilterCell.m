//
//  STKFilterCell.m
//  Prism
//
//  Created by Joe Conway on 2/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKFilterCell.h"

@implementation STKFilterCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

- (IBAction)showSinglePanePosts:(id)sender
{
    ROUTE(sender);
}

- (IBAction)showGridPosts:(id)sender
{
    ROUTE(sender);
}

- (IBAction)toggleFilterByUserPost:(id)sender
{
    ROUTE(sender);
}

- (IBAction)toggleFilterbyLocation:(id)sender
{
    ROUTE(sender);
}
@end
