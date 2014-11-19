//
//  STKDateBar.m
//  Prism
//
//  Created by Joe Conway on 5/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKDateBar.h"

@interface STKDateBar ()
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) NSArray *labels;
@end

@implementation STKDateBar

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

- (NSArray *)labelsForCurrentRange
{
    NSMutableArray *a = [NSMutableArray array];
   
    NSString *currString = nil;
    for(int i = [self lastWeekInYear]; i >= [self lastWeekInYear] - 6; i--) {
        
        int thisWeek = i;
        int thisYear = [self year];
        if(thisWeek <= 0) {
            thisWeek = 52 + i;
            thisYear = [self year] - 1;
        }
        
        NSString *newStr = [self stringForWeek:thisWeek year:thisYear];
        if(![newStr isEqualToString:currString]) {
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, [self bounds].size.height)];
            [lbl setNumberOfLines:2];
            [lbl setFont:STKFont(12)];
            [lbl setTranslatesAutoresizingMaskIntoConstraints:NO];
            [lbl setTextColor:[UIColor HATextColor]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setText:newStr];
            [a addObject:lbl];
        }
        
        currString = newStr;
    }

    return a;
}

- (void)setLabels:(NSArray *)labels
{
    [[self labels] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _labels = labels;
    
    for(UILabel *lbl in _labels) {
        [self addSubview:lbl];
        [lbl addConstraint:[NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                           toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                           toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
    }
    
    if([_labels count] == 3) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[l]-8-[lv(==cv)]-8-[cv(==rv)]-8-[rv]-8-[r]" options:0
                                                                     metrics:nil
                                                                       views:@{@"l" : _leftButton,
                                                                               @"lv" : [_labels objectAtIndex:2],
                                                                               @"cv" : [_labels objectAtIndex:1],
                                                                               @"rv" : [_labels objectAtIndex:0],
                                                                               @"r" : _rightButton}]];
         
         
    } else if([_labels count] == 2) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[l]-8-[lv(==rv)]-8-[rv]-8-[r]" options:0
                                                                     metrics:nil
                                                                       views:@{@"l" : _leftButton,
                                                                               @"lv" : [_labels objectAtIndex:1],
                                                                               @"rv" : [_labels objectAtIndex:0],
                                                                               @"r" : _rightButton}]];
        
        
    }

}

- (NSString *)stringForWeek:(int)week year:(int)year
{
    NSDateComponents *dc = [[NSDateComponents alloc] init];
    [dc setWeekOfYear:week];
    [dc setYearForWeekOfYear:year];
    [dc setWeekday:1];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [cal dateFromComponents:dc];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM\nyyyy"];
    return [df stringFromDate:date];
    
}

- (void)commonInit
{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, [[UIScreen mainScreen] scale]);
    [[UIColor HATextColor] set];

    UIBezierPath *bp = [UIBezierPath bezierPath];
    [bp setLineWidth:2];
    [bp moveToPoint:CGPointMake(20, 8)];
    [bp addLineToPoint:CGPointMake(12, 15)];
    [bp addLineToPoint:CGPointMake(20, 22)];
    [bp stroke];
    UIImage *leftImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, [[UIScreen mainScreen] scale]);
    [[UIColor HATextColor] set];
    bp = [UIBezierPath bezierPath];
    [bp setLineWidth:2];

    [bp moveToPoint:CGPointMake(10, 8)];
    [bp addLineToPoint:CGPointMake(18, 15)];
    [bp addLineToPoint:CGPointMake(10, 22)];
    [bp stroke];

    UIImage *rightImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftButton setFrame:CGRectMake(0, 0, 30, 30)];
    [_leftButton setImage:leftImage forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(moveDateEarlier:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftButton];

    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setFrame:CGRectMake(0, 0, 30, 30)];

    [_rightButton setImage:rightImage forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(moveDateLater:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];

    for(UIView *v in [self subviews]) {
        [v setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[v(==30)]" options:0 metrics:nil views:@{@"v" : _leftButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[v(==30)]|" options:0 metrics:nil views:@{@"v" : _rightButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:0 views:@{@"v" : _leftButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:0 views:@{@"v" : _rightButton}]];

    NSDate *today = [NSDate date];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dc = [cal components:NSYearForWeekOfYearCalendarUnit | NSWeekOfYearCalendarUnit fromDate:today];
    
    [self setLastWeekInYear:(int)[dc weekOfYear]];
    [self setYear:(int)[dc yearForWeekOfYear]];
    [self setLabels:[self labelsForCurrentRange]];

}

- (void)moveDateEarlier:(id)sender
{
    int earlier = [self lastWeekInYear] - 7;
    if(earlier <= 0) {
        [self setYear:[self year] - 1];
        [self setLastWeekInYear:52 + earlier];
    } else {
        [self setLastWeekInYear:earlier];
    }
    
    [self setLabels:[self labelsForCurrentRange]];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)moveDateLater:(id)sender
{
    int later = [self lastWeekInYear] + 7;
    if(later > 52) {
        [self setYear:[self year] + 1];
        [self setLastWeekInYear:later - 52];
    } else {
        [self setLastWeekInYear:later];
    }
    
    [self setLabels:[self labelsForCurrentRange]];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
