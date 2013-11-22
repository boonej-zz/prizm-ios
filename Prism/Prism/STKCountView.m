//
//  STKCountView.m
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKCountView.h"

@implementation STKCountView

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
        [self setJoinDate:[NSDate date]];
    }
    return self;
}

- (void)commonInit
{
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setFollowerCount:(int)followerCount
{
    _followerCount = followerCount;
    [self setNeedsDisplay];
}

- (void)setFollowingCount:(int)followingCount
{
    _followingCount = followingCount;
    [self setNeedsDisplay];
}

- (void)setPostCount:(int)postCount
{
    _postCount = postCount;
    [self setNeedsDisplay];
}

- (void)setJoinDate:(NSDate *)joinDate
{
    _joinDate = joinDate;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = [self bounds];
    
    float circleHeight = b.size.height / 1.8;
    float remainingAfterCircle = b.size.height - circleHeight;
    float topPadding = remainingAfterCircle / 3.0;
    float horizontalRemaining = b.size.width - circleHeight * 3.0;
    float horizontalMajor = horizontalRemaining * 2.0 / 3.0;
    float horizontalMinor = horizontalRemaining * 1.0 / 3.0;
    
    [[UIColor colorWithWhite:1.0 alpha:0.1] setFill];
    [[UIColor colorWithWhite:0.2 alpha:0.2] setStroke];
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, circleHeight, circleHeight)];
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeZero, 5, [[UIColor darkGrayColor] CGColor]);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, topPadding);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), horizontalMinor / 2.0, 0);
    [bp fill];
    [bp stroke];
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), circleHeight + horizontalMajor / 2.0, 0);
    [bp fill];
    [bp stroke];

    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), circleHeight + horizontalMajor / 2.0, 0);
    [bp fill];
    [bp stroke];

    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    
    float cx = horizontalMinor / 2.0 + circleHeight / 2.0;
    float cy = topPadding + circleHeight / 2.0;
    UIFont *smallFont = [UIFont systemFontOfSize:16];
    UIFont *largeFont = [UIFont systemFontOfSize:18];
    NSDictionary *smallAttrs = @{NSFontAttributeName : smallFont, NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]};
    NSDictionary *largeAttrs = @{NSFontAttributeName : largeFont, NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]};
    
    NSString *s = @"Followers";
    CGSize sz = [s sizeWithAttributes:smallAttrs];
    [s drawInRect:CGRectMake(cx - sz.width / 2.0, cy - sz.height, sz.width, sz.height) withAttributes:smallAttrs];
    s = [NSString stringWithFormat:@"%d", [self followerCount]];
    sz = [s sizeWithAttributes:largeAttrs];
    [s drawInRect:CGRectMake(cx - sz.width / 2.0, cy, sz.width, sz.height) withAttributes:largeAttrs];
    
    s = @"Following";
    sz = [s sizeWithAttributes:smallAttrs];
    [s drawInRect:CGRectMake(cx - sz.width / 2.0 + circleHeight + horizontalMajor / 2.0, cy - sz.height, sz.width, sz.height) withAttributes:smallAttrs];
    s = [NSString stringWithFormat:@"%d", [self followingCount]];
    sz = [s sizeWithAttributes:largeAttrs];
    [s drawInRect:CGRectMake(cx - sz.width / 2.0 + circleHeight + horizontalMajor / 2.0, cy, sz.width, sz.height) withAttributes:largeAttrs];

    s = @"Posts";
    sz = [s sizeWithAttributes:smallAttrs];
    [s drawInRect:CGRectMake(cx - sz.width / 2.0 + 2.0 * (circleHeight + horizontalMajor / 2.0), cy - sz.height, sz.width, sz.height) withAttributes:smallAttrs];
    s = [NSString stringWithFormat:@"%d", [self postCount]];
    sz = [s sizeWithAttributes:largeAttrs];
    [s drawInRect:CGRectMake(cx - sz.width / 2.0 + 2.0 * (circleHeight + horizontalMajor / 2.0), cy, sz.width, sz.height) withAttributes:largeAttrs];

    float pillWidth = 150;
    [[UIColor colorWithWhite:1.0 alpha:0.1] setFill];
    bp = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(b.size.width / 2.0 - pillWidth / 2.0, b.size.height - 30, 150, 24)
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:CGSizeMake(4, 4)];
    [bp fill];
    
    static NSDateFormatter *df = nil;
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM yyyy"];
    }
    smallFont = [UIFont systemFontOfSize:12];
    smallAttrs = @{NSFontAttributeName : smallFont, NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]};
    s = [NSString stringWithFormat:@"Member since %@", [df stringFromDate:[self joinDate]]];
    sz = [s sizeWithAttributes:smallAttrs];
    [s drawInRect:CGRectMake(b.size.width / 2.0 - sz.width / 2.0, b.size.height - 24, sz.width, sz.height) withAttributes:smallAttrs];
}


@end
