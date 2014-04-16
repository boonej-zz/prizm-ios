//
//  STKActivityCell.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKActivityCell.h"

@implementation STKActivityCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (IBAction)profileImageTapped:(id)sender
{
    ROUTE(sender);
}

- (void)layoutContent
{
    
}

@end
