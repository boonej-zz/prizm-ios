//
//  HAGroupCell.m
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAGroupCell.h"

@interface HAGroupCell()

@property (nonatomic, strong) IBOutlet UILabel *countLabel;

@end

@implementation HAGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.countView setHidden:YES];
    [self setMessageCount:@0];
    [self.title setText:@""];
    
}

- (void)awakeFromNib {
    // Initialization code
    [self.title setFont:STKFont(18.0f)];
    [self.countLabel setTextColor:[UIColor HATextColor]];
    [self.countLabel setFont:STKBoldFont(12)];
    [self.title setTextColor:[UIColor whiteColor]];
    [self.countView setBackgroundColor:[UIColor colorWithRed:0.3 green:0.4 blue:.7 alpha:1]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 48.0f)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
    [self.countView.layer setCornerRadius:11.f];
    [self setSelectedBackgroundView:bgView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageCount:(NSNumber *)count
{
    [self.countLabel setText:[count stringValue]];
    [self.countView setHidden:(count.intValue <= 0)];
}

@end
