//
//  HAInterestCell.m
//  Prizm
//
//  Created by Jonathan Boone on 10/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAInterestCell.h"
#import "STKInterest.h"
#import <QuartzCore/QuartzCore.h>

@interface HAInterestCell()

@property (nonatomic, weak) IBOutlet UILabel *label;

@end


@implementation HAInterestCell

@synthesize selected = _selected;

- (void)prepareForReuse
{
    [self setSelected:NO];
    [self setStored:NO];
    [super prepareForReuse];
}

- (void)awakeFromNib {
    // Initialization code
    [self.label setFont:STKFont(16)];
    self.layer.cornerRadius = 12;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)setInterest:(STKInterest *)interest
{
    _interest = interest;
    [self styleCell];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self styleCell];
}

- (void)setStored:(BOOL)stored
{
    _stored = stored;
    [self styleCell];
}

- (void)styleCell
{
//    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
//        self.label.center = CGPointMake(self.frame.size.height/2, self.frame.size.width/2);
//    }
    if ([self isSelected] || [self isStored]) {
        NSString *textString = [self.interest.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self.label setText:[NSString stringWithFormat:@"#%@", [textString lowercaseString]]];
    } else {
        [self.label setText:[self.interest.text capitalizedString]];
    }
    if ([self isSelected] && ![self isStored]) {
        [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
        [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
        [self.label setTextColor:STKSelectedTextColor];
    } else {
        [self.label setTextColor:[UIColor whiteColor]];
    }
    
    if ([self isStored]) {
        [self setBackgroundColor:[UIColor colorWithRed:14.f/255.f green:132.f/255.f blue:218.f/255.f alpha:0.4f]];
    }
    
    if (![self isStored] && ![self isSelected]) {
        [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    }
    
}


@end
