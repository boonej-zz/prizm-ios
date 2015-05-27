//
//  STKSearchProfileCell.m
//  Prism
//
//  Created by Joe Conway on 1/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSearchProfileCell.h"

@implementation STKSearchProfileCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _underlayView = [[UIView alloc] init];
        [_underlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_underlayView setHidden:YES];
        [self insertSubview:_underlayView atIndex:0];
        [self setConstriants];
        
    }
    return self;
}

- (void)setConstriants
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[uv]-0-|" options:0 metrics:nil views:@{@"uv": _underlayView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[uv]-0-|" options:0 metrics:nil views:@{@"uv": _underlayView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_underlayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_underlayView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:-1.f]];
}

- (void)layoutSubviews
{
    [self.underlayView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2f]];
    [super layoutSubviews];
}

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

}

- (void)layoutContent
{
    
}

- (IBAction)sendMessage:(id)sender
{
    ROUTE(sender);
}

- (IBAction)toggleFollow:(id)sender
{
    ROUTE(sender);
}

- (IBAction)cancelTrust:(id)sender
{
    ROUTE(sender);
}

@end
