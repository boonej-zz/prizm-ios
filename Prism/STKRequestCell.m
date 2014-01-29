//
//  STKRequestCell.m
//  Prism
//
//  Created by Joe Conway on 1/29/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKRequestCell.h"

@implementation STKRequestCell

- (void)cellDidLoad
{
    
}

- (void)layoutContent
{
    
}

- (IBAction)acceptRequest:(id)sender
{
    ROUTE(sender);
}

- (IBAction)rejectRequest:(id)sender
{
    ROUTE(sender);
}
@end
