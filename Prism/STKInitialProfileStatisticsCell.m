//
//  STKInitialProfileStatisticsCell.m
//  Prism
//
//  Created by Joe Conway on 1/8/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInitialProfileStatisticsCell.h"

@implementation STKInitialProfileStatisticsCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)layoutContent
{
    
}

- (IBAction)editProfile:(id)sender
{
    ROUTE(sender);
}
- (IBAction)requestTrust:(id)sender
{
    ROUTE(sender);
}

- (IBAction)follow:(id)sender
{
    ROUTE(sender);
}

- (IBAction)showAccolades:(id)sender
{
    ROUTE(sender);
}

- (IBAction)showTrusts:(id)sender
{
    ROUTE(sender);
}

- (IBAction)sendMessage:(id)sender
{
    ROUTE(sender);
}

- (IBAction)share:(id)sender
{
    ROUTE(sender);
}

@end
