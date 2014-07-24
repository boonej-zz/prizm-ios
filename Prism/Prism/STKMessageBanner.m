//
//  STKMessageBanner.m
//  Prism
//
//  Created by DJ HAYDEN on 7/21/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKMessageBanner.h"

CGFloat const STKMessageBannerHeight = 20.0f;

@interface STKMessageBanner()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSLayoutConstraint *labelHeight;

@end

@implementation STKMessageBanner

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, STKMessageBannerHeight)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setClipsToBounds:NO];
        [self setHidden:YES];
        
        _label = [[UILabel alloc] initWithFrame:[self frame]];
        [_label setClipsToBounds:YES];
        [_label setBackgroundColor:[self colorForBannerType:STKMessageBannerTypeError]];
        [_label setAlpha:0.8];
        [_label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.f]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setTextColor:[UIColor colorWithWhite:1.f alpha:0.9f]];
        [[_label layer] setShadowColor:[UIColor blackColor].CGColor];
        [[_label layer] setShadowOffset:CGSizeMake(0.f, -1.f)];
        [[_label layer] setShadowOpacity:0.3f];
        [[_label layer] setShadowRadius:0.f];
        
        [self addSubview:_label];
        
    }
    return self;
}

- (NSString *)labelText
{
    return [[self label] text];
}

- (void)setLabelText:(NSString *)labelText
{
    [[self label] setText:labelText];
    
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (void)setType:(STKMessageBannerType)type
{
    [[self label] setBackgroundColor:[self colorForBannerType:type]];
}

- (void)setVisible:(BOOL)visible
{
    [self setHidden:!visible];
    
    if(!visible) {
        [self setLabelText:@""];
        [[self label] setBackgroundColor:[UIColor clearColor]];
    } else {
        [[self label] setBackgroundColor:[self colorForBannerType:[self type]]];
    }
}

- (BOOL)isVisible
{
    return ![self isHidden];
}

- (UIColor *)colorForBannerType:(STKMessageBannerType)type
{
    NSArray *colorMap = @[[UIColor redColor],
                          [UIColor yellowColor],
                          [UIColor greenColor],
                          [UIColor orangeColor]];
    
    if(![colorMap objectAtIndex:(int)type]) {
        return [colorMap objectAtIndex:(int)STKMessageBannerTypeError];
    }
    
    return [colorMap objectAtIndex:(int)type];
}

@end
