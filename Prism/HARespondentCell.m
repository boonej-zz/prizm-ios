//
//  HARespondentCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/13/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HARespondentCell.h"
#import "STKAvatarView.h"
#import "STKUser.h"

@interface HARespondentCell()

@property (nonatomic, strong) STKAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *durationLabel;

@end

@implementation HARespondentResult



@end

@implementation HARespondentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutViews];
        [self layoutConstraints];
    }
    return self;
}

#pragma mark Configuration

- (void)layoutViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectedBackgroundView:[[UIView alloc] init]];
    self.avatarView = [[STKAvatarView alloc] init];
    [self.avatarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.avatarView];
    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nameLabel setFont:STKFont(13)];
    [self.nameLabel setTextColor:[UIColor HATextColor]];
    [self.nameLabel sizeToFit];
    [self addSubview:self.nameLabel];
    self.dateLabel = [[UILabel alloc] init];
    [self.dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dateLabel setFont:STKFont(12)];
    [self.dateLabel setTextColor:[UIColor HATextColor]];
    [self addSubview:self.dateLabel];
    self.timeLabel = [[UILabel alloc] init];
    [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.timeLabel setFont:STKFont(12)];
    [self.timeLabel setTextColor:[UIColor HATextColor]];
    [self addSubview:self.timeLabel];
    self.durationLabel = [[UILabel alloc] init];
    [self.durationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.durationLabel setFont:STKFont(12)];
    [self.durationLabel setTextColor:[UIColor HATextColor]];
    [self addSubview:self.durationLabel];
}

- (void)layoutConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-17-[av(==30)]-11-[nl]" options:0 metrics:nil views:@{@"av":self.avatarView, @"nl":self.nameLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[nl]-0-[dl]" options:0 metrics:nil views:@{@"nl": self.nameLabel, @"dl": self.dateLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeLeft multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeHeight multiplier:0.f constant:50.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeRight multiplier:1.f constant:8.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.timeLabel attribute:NSLayoutAttributeHeight multiplier:0.f constant:50.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.timeLabel attribute:NSLayoutAttributeRight multiplier:1.f constant:8.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.durationLabel attribute:NSLayoutAttributeHeight multiplier:0.f constant:50.f]];
}

- (void)setResult:(HARespondentResult *)result
{
    _result = result;
    [self.nameLabel setText:result.user.name];
    [self.nameLabel sizeToFit];
    [self.avatarView setUrlString:result.user.profilePhotoPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yy"];
    if (result.completeDate) {
        [self.dateLabel setHidden:NO];
        [self.timeLabel setHidden:NO];
        [self.dateLabel setText:[dateFormatter stringFromDate:result.completeDate]];
        [dateFormatter setDateFormat:@"h:mma"];
        [self.timeLabel setText:[dateFormatter stringFromDate:result.completeDate]];
        if (result.startDate) {
            [self.durationLabel setHidden:NO];
            NSTimeInterval duration = [result.completeDate timeIntervalSinceDate:result.startDate];
            NSDate *durationDate = [NSDate dateWithTimeIntervalSince1970:duration];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [self.durationLabel setText:[dateFormatter stringFromDate:durationDate]];
        }
    } else {
        [self.dateLabel setHidden:YES];
        [self.timeLabel setHidden:YES];
        [self.durationLabel setHidden:YES];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGFloat startX = 17;
    CGFloat endX = rect.size.width;
    CGFloat y = rect.size.height - 1;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1.0);
    CGFloat red[4]={168.f/255.f, 171.f/255.f, 176.f/255.f, 0.5f};
    CGContextSetStrokeColor(c, red);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, startX, y);
    CGContextAddLineToPoint(c, endX, y);
    CGContextStrokePath(c);
    [super drawRect:rect];
}

@end
