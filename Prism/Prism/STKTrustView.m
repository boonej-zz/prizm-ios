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
#import "STKAvatarView.h"
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
        STKCircleView *sv = [[STKCircleView alloc] initWithFrame:CGRectMake(0, 0, [[self class] minorCircleSize], [[self class] minorCircleSize])];
        [sv addTarget:self
               action:@selector(circleTapped:)
     forControlEvents:UIControlEventTouchUpInside];
        [a addObject:sv];
        [self addSubview:sv];
        
        if(i > 0) {
            [sv setOverlayText:[NSString stringWithFormat:@"%d", i]];
        }
    }
    [self setCircleViews:[a copy]];
    [[[self circleViews] objectAtIndex:0] setFrame:CGRectMake(0, 0, 75, 75)];
    /*
    _spinLayer = [CALayer layer];
    [[self spinLayer] setBounds:CGRectMake(0, 0, 8, 8)];
    [[self spinLayer] setBackgroundColor:[[UIColor clearColor] CGColor]];
    [[self spinLayer] setContents:(__bridge id)[[UIImage imageNamed:@"explosion.png"] CGImage]];
    [[self layer] addSublayer:[self spinLayer]];
    [[self spinLayer] setHidden:YES];*/
}

+ (float)minorCircleSize
{
    return 53;
}

- (void)circleTapped:(id)sender
{
    NSInteger idx = [[self circleViews] indexOfObject:sender];
    if(idx == 0)
        return;
    
    [[self delegate] trustView:self didSelectCircleAtIndex:(int)idx - 1];
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
    
    float indexHeight1, indexHeight2, indexHeight3, indexHeight4, indexHeight5;
    
    if([[UIScreen mainScreen] bounds].size.height > 500) {
        indexHeight1 = 175;
        indexHeight2 = b.size.height / 2.0 - 85;
        indexHeight3 = b.size.height / 2.0 + 90;
        indexHeight4 = b.size.height / 2.0 + 70;
        indexHeight5 = b.size.height / 2.0 - 87;
    } else {
        indexHeight1 = 120;
        indexHeight2 = b.size.height / 2.0 - 75;
        indexHeight3 = b.size.height / 2.0 + 80;
        indexHeight4 = b.size.height / 2.0 + 60;
        indexHeight5 = b.size.height / 2.0 - 77;
    }
    
    [[[self circleViews] objectAtIndex:0] setCenter:CGPointMake(b.size.width / 2.0, b.size.height / 2.0)];
    [[[self circleViews] objectAtIndex:1] setCenter:CGPointMake(b.size.width - 75, indexHeight1)];
    [[[self circleViews] objectAtIndex:2] setCenter:CGPointMake(b.size.width / 2.0 + 35, indexHeight2)];
    [[[self circleViews] objectAtIndex:3] setCenter:CGPointMake(b.size.width / 2.0 + 45, indexHeight3)];
    [[[self circleViews] objectAtIndex:4] setCenter:CGPointMake(b.size.width / 2.0 - 90, indexHeight4)];
    [[[self circleViews] objectAtIndex:5] setCenter:CGPointMake(b.size.width / 2.0 - 90, indexHeight5)];
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
        [(STKCircleView *)[[self circleViews] objectAtIndex:selectedIndex] setBorderColor:STKLightBlueColor];
        
        if(prev != _selectedIndex) {
            CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            CGRect r = [[[self circleViews] objectAtIndex:selectedIndex] frame];
            
            CGPoint center = [[[self circleViews] objectAtIndex:selectedIndex] center];

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
    
    for(int i = 1; i != 6; i++) {
        STKCircleView *cv = [[self circleViews] objectAtIndex:i];
        if (i < [self.circleViews count]){
            
            if(i - 1 < [[self users] count] && i - 1 >= 0) {
                
                STKUser *u = [[self users] objectAtIndex:i - 1];
                
                if ([u profilePhotoPath]) {
                    [[STKImageStore store] fetchImageForURLString:[u profilePhotoPath] preferredSize:STKImageStoreThumbnailMedium completion:^(UIImage *img) {
                        [cv setImage:img];
                    }];
                } else {
                    [cv setImage:[STKAvatarView defaultAvatarImage:[cv bounds]]];
                }
            } else {
                [cv setImage:nil];
            }
        } else {
            [cv setImage:nil];
        }
    }
    [self setNeedsDisplay];
}

- (CGPoint)lineEndpointForLineFrom:(CGPoint)from to:(CGPoint)to minusLength:(float)minusLength
{
    float dist = sqrtf(powf(from.x - to.x, 2) + powf(from.y - to.y, 2));
    
    float x = (to.x - from.x) / dist;
    float y = (to.y - from.y) / dist;

    dist -= minusLength;
    dist += 1;
    
    return CGPointMake(from.x + x * dist, from.y + y * dist);
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = [self bounds];
    [[STKTextColor colorWithAlphaComponent:0.5] set];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    CGPoint initialPoint = CGPointMake(b.size.width / 2.0, b.size.height / 2.0);
    [bp moveToPoint:initialPoint];
    [bp addLineToPoint:[self lineEndpointForLineFrom:initialPoint to:[[[self circleViews] objectAtIndex:1] center] minusLength:[[self class] minorCircleSize] / 2.0]];

    [bp moveToPoint:initialPoint];
    [bp addLineToPoint:[self lineEndpointForLineFrom:initialPoint to:[[[self circleViews] objectAtIndex:2] center] minusLength:[[self class] minorCircleSize] / 2.0]];

    [bp moveToPoint:initialPoint];
    [bp addLineToPoint:[self lineEndpointForLineFrom:initialPoint to:[[[self circleViews] objectAtIndex:3] center] minusLength:[[self class] minorCircleSize] / 2.0]];
    
    [bp moveToPoint:initialPoint];
    [bp addLineToPoint:[self lineEndpointForLineFrom:initialPoint to:[[[self circleViews] objectAtIndex:4] center] minusLength:[[self class] minorCircleSize] / 2.0]];

    [bp moveToPoint:initialPoint];
    [bp addLineToPoint:[self lineEndpointForLineFrom:initialPoint to:[[[self circleViews] objectAtIndex:5] center] minusLength:[[self class] minorCircleSize] / 2.0]];
    
    [bp setLineWidth:2];
    [bp stroke];
}

@end
