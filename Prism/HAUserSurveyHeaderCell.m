//
//  HAUserSurveyHeaderself.m
//  Prizm
//
//  Created by Jonathan Boone on 8/6/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAUserSurveyHeaderCell.h"

@implementation HAUserSurveyHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.15f]];
        
        CGRect frame = [UIScreen mainScreen].bounds;
        frame.size.height = 48.f;
        UIView *view = nil;
        
        if (IS_HEIGHT_GTE_568 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            view = [[UIVisualEffectView alloc] initWithEffect:blur];
            [view setFrame:frame];
            UIView *dv = [[UIView alloc] initWithFrame:frame];
            [dv setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.34f]];
            //        UIVibrancyEffect *ve = [UIVibrancyEffect effectForBlurEffect:blur];
            //        UIVisualEffectView *vev = [[UIVisualEffectView alloc] initWithEffect:ve];
            //        [vev setFrame:frame];
            
            //        [[(UIVisualEffectView *)view contentView] addSubview:vev];
            [[(UIVisualEffectView *)view contentView] addSubview:dv];
        } else {
            view = [[UIImageView alloc] initWithFrame:frame];
//            [(UIImageView *)view setImage:[UIImage HABackgroundImage]];
//            [(UIImageView *)view setContentMode:UIViewContentModeTopLeft];
//            [view setAlpha:0.95];
//            [view setClipsToBounds:YES];
        }
        
        [self addSubview:view];
        NSArray *horizontalConstatraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v(>=300)]-0-|" options:0 metrics:nil views:@{@"v": view}];
        NSString *verticalString = [NSString stringWithFormat:@"V:|-0-[v(==48)]"];
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalString options:0 metrics:nil views:@{@"v": view}];
        view.tag = 99999;
        [self addConstraints:horizontalConstatraints];
        [self addConstraints:verticalConstraints];
        
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [titleLabel setText:@"Title"];
        [titleLabel setFont:STKFont(15)];
        [titleLabel setTextColor:[UIColor HATextColor]];
        [self addSubview:titleLabel];
        
        UILabel *rankLabel = [[UILabel alloc] init];
        [rankLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [rankLabel setText:@"Rank"];
        [rankLabel setFont:STKFont(15)];
        [rankLabel setTextColor:[UIColor HATextColor]];
        [self addSubview:rankLabel];
        
        UILabel *durationLabel = [[UILabel alloc] init];
        [durationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [durationLabel setText:@"Duration"];
        [durationLabel setFont:STKFont(15)];
        [durationLabel setTextColor:[UIColor HATextColor]];
        [self addSubview:durationLabel];
        
        UILabel *pointsLabel = [[UILabel alloc] init];
        [pointsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [pointsLabel setText:@"Points"];
        [pointsLabel setFont:STKFont(15)];
        [pointsLabel setTextColor:[UIColor HATextColor]];
        [self addSubview:pointsLabel];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[tl]-2-[rl(==35)]-16-[dl(==56)]-13-[pt(==42)]-15-|" options:0 metrics:nil views:@{@"tl": titleLabel, @"rl": rankLabel, @"dl": durationLabel, @"pt": pointsLabel}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:rankLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:durationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:pointsLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    CGFloat x = rect.size.width - 63.5;
    CGFloat startY = (rect.size.height / 2) - 6.75;
    CGFloat endY = startY + 13.5;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1.0);
    CGFloat red[4]={168.f/255.f, 171.f/255.f, 176.f/255.f, 0.5f};
    CGContextSetStrokeColor(c, red);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x, startY);
    CGContextAddLineToPoint(c, x, endY);
    CGContextStrokePath(c);
    x = x - 70.5;
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x, startY);
    CGContextAddLineToPoint(c, x, endY);
    CGContextStrokePath(c);
    [super drawRect:rect];
}

@end
