//
//  STKTrustView.m
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTrustView.h"
#import "STKCircleView.h"
#import "STKUser.h"
#import "STKImageStore.h"

@interface STKTrustView ()
@property (nonatomic, strong) NSArray *circleViews;
@end

@implementation STKTrustView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSMutableArray *a = [NSMutableArray array];
    for(int i = 0; i < 6; i++) {
        STKCircleView *sv = [[STKCircleView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [sv addTarget:self action:@selector(circleTapped:)
     forControlEvents:UIControlEventTouchUpInside];
        [a addObject:sv];
        [self addSubview:sv];
    }
    [self setCircleViews:[a copy]];
    [[[self circleViews] objectAtIndex:0] setFrame:CGRectMake(0, 0, 75, 75)];
}

- (void)circleTapped:(id)sender
{
    NSInteger idx = [[self circleViews] indexOfObject:sender];
    [[self delegate] trustView:self didSelectCircleAtIndex:(int)idx];
}

- (void)setUser:(STKUser *)user
{
    _user = user;
    [[STKImageStore store] fetchImageForURLString:[user profilePhotoPath] preferredSize:STKImageStoreThumbnailLarge completion:^(UIImage *img) {
        [[[self circleViews] objectAtIndex:0] setImage:img];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect b = [self bounds];

    [[[self circleViews] objectAtIndex:0] setCenter:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [[[self circleViews] objectAtIndex:1] setCenter:CGPointMake(b.size.width - 75, 175)];
    [[[self circleViews] objectAtIndex:2] setCenter:CGPointMake(b.size.width / 2.0 + 35, b.size.height / 2.0 - 85)];
    [[[self circleViews] objectAtIndex:3] setCenter:CGPointMake(b.size.width / 2.0 + 45, b.size.height / 2.0 + 90)];
    [[[self circleViews] objectAtIndex:4] setCenter:CGPointMake(b.size.width / 2.0 - 90, b.size.height / 2.0 + 70)];
    [[[self circleViews] objectAtIndex:5] setCenter:CGPointMake(b.size.width / 2.0 - 90, b.size.height / 2.0 - 87)];
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    
    for(int i = 0; i < [users count] && i + 1 < [[self circleViews] count]; i++) {
        STKCircleView *cv = [[self circleViews] objectAtIndex:i + 1];
        STKUser *u = [[self users] objectAtIndex:i];
        
        [[STKImageStore store] fetchImageForURLString:[u profilePhotoPath] preferredSize:STKImageStoreThumbnailMedium completion:^(UIImage *img) {
            [cv setImage:img];
        }];
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = [self bounds];
    [[UIColor colorWithWhite:1 alpha:0.4] set];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    if([[self users] count] > 0) {
        [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
        [bp addLineToPoint:[[[self circleViews] objectAtIndex:1] center]];
    }

    if([[self users] count] > 1) {
        [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
        [bp addLineToPoint:[[[self circleViews] objectAtIndex:2] center]];
    }

    if([[self users] count] > 2) {
        [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
        [bp addLineToPoint:[[[self circleViews] objectAtIndex:3] center]];
        
    }
    
    if([[self users] count] > 3) {
        [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
        [bp addLineToPoint:[[[self circleViews] objectAtIndex:4] center]];
    }

    if([[self users] count] > 4) {
        [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
        [bp addLineToPoint:[[[self circleViews] objectAtIndex:5] center]];
    }
    
    [bp setLineWidth:2];
    [bp stroke];


}

@end
