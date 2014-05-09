//
//  STKGraphCell.m
//  Prism
//
//  Created by Joe Conway on 5/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKGraphCell.h"

@implementation STKGraphCell

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[self colorWell] setClipsToBounds:YES];
    [[[self colorWell] layer] setCornerRadius:4];
}

- (void)layoutContent
{
    
}

@end
