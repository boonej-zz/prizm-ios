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
@import QuartzCore;

@interface STKTrustView ()
@property (nonatomic, strong) NSArray *circleViews;
@property (nonatomic, strong) CALayer *spinLayer;
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
    
    _spinLayer = [CALayer layer];
    [[self spinLayer] setBounds:CGRectMake(0, 0, 8, 8)];
    [[self spinLayer] setBackgroundColor:[[UIColor clearColor] CGColor]];
    [[self spinLayer] setContents:(__bridge id)[[UIImage imageNamed:@"explosion.png"] CGImage]];
    [[self layer] addSublayer:[self spinLayer]];
    [[self spinLayer] setHidden:YES];
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

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    NSInteger prev = _selectedIndex;
    
    _selectedIndex = selectedIndex;
    
    for(STKCircleView *cv in [self circleViews]) {
        [cv setBorderColor:nil];
    }
    
    if(_selectedIndex == 0) {
        [[self spinLayer] removeAllAnimations];
        [[self spinLayer] setHidden:YES];
    } else {
        [[self spinLayer] setHidden:NO];
        
        if(prev != _selectedIndex) {
            CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            CGRect r = [[[self circleViews] objectAtIndex:selectedIndex] frame];
            
            CGPoint center = [[[self circleViews] objectAtIndex:selectedIndex] center];
            [(STKCircleView *)[[self circleViews] objectAtIndex:selectedIndex] setBorderColor:STKLightBlueColor];
            float radius = r.size.width / 2.0 - 1;
            NSMutableArray *points = [NSMutableArray array];
            for(float angle = 0; angle <= 2 * M_PI; angle += M_PI / 32) {
                CGPoint p = CGPointZero;
                p.x = center.x + radius * cos(angle);
                p.y = center.y + radius * sin(angle);
                [points addObject:[NSValue valueWithCGPoint:p]];
            }
            [kf setDuration:2];
            [kf setRepeatCount:100000];
            [kf setValues:points];
            [[self spinLayer] addAnimation:kf forKey:@"spin"];
        }
    }
    
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
    [STKTextColor set];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:[[[self circleViews] objectAtIndex:1] center]];
    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:[[[self circleViews] objectAtIndex:2] center]];
    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:[[[self circleViews] objectAtIndex:3] center]];
    
    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:[[[self circleViews] objectAtIndex:4] center]];
    [bp moveToPoint:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [bp addLineToPoint:[[[self circleViews] objectAtIndex:5] center]];
    [bp setLineWidth:2];
    [bp stroke];


}

@end
