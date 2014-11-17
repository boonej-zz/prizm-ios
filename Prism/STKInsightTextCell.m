//
//  STKInsightTextCell.m
//  Prizm
//
//  Created by Jonathan Boone on 10/7/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInsightTextCell.h"
#import "STKInsightTarget.h"
#import "STKInsight.h"

@implementation STKInsightTextCell

- (void)awakeFromNib {
    // Initialization code
    [self setBackgroundColor:[UIColor clearColor]];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    [self.textView setEditable:NO];
    [self.textView setTextColor:STKTextColor];
    [self.textView setFont:STKFont(16)];
                                                                                                                    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInsightTarget:(STKInsightTarget *)insightTarget
{
    _insightTarget = insightTarget;
    UIColor *blueColor = [UIColor colorWithRed:81.f/255.f green:180.f/255.f blue:250.f/255.f alpha:0.8f];
    [self.textView setLinkTextAttributes:@{NSForegroundColorAttributeName: blueColor}];
    NSMutableAttributedString *mat = [[NSMutableAttributedString alloc] init];
    [mat appendAttributedString:[[NSAttributedString alloc] initWithString:insightTarget.insight.text attributes:@{NSFontAttributeName: STKFont(16), NSForegroundColorAttributeName: STKTextColor}]];
    [mat appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n" attributes:nil]];
    NSAttributedString *linkString = [[NSAttributedString alloc] initWithString:self.insightTarget.insight.linkTitle attributes:@{NSFontAttributeName: STKFont(20), NSForegroundColorAttributeName: blueColor, NSLinkAttributeName: [self.insightTarget.insight linkURL]}];
    [mat appendAttributedString:linkString];
    [self.textView setAttributedText:mat];
    
}

@end
