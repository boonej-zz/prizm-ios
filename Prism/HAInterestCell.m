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

- (void)awakeFromNib {
    // Initialization code
    [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.label setFont:STKFont(16)];
    [self.label setTextColor:[UIColor whiteColor]];
    self.layer.cornerRadius = 12;
}

- (void)setInterest:(STKInterest *)interest
{
    _interest = interest;
    [self.label setText:[self.interest.text capitalizedString]];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        NSString *textString = [self.interest.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self.label setText:[NSString stringWithFormat:@"#%@", [textString lowercaseString]]];
        [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
        [self.label setTextColor:STKSelectedTextColor];
    } else {
        [self.label setText:[self.interest.text capitalizedString]];
        [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
        [self.label setTextColor:[UIColor whiteColor]];
    }
}


@end
