//
//  STKSearchProfileCell.m
//  Prism
//
//  Created by Joe Conway on 1/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSearchProfileCell.h"

@implementation STKSearchProfileCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

- (IBAction)toggleFollow:(id)sender
{
    ROUTE(sender);
}
@end
