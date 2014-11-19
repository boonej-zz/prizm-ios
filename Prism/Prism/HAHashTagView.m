//
//  HAHashTagView.m
//  Prizm
//
//  Created by Jonathan Boone on 9/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAHashTagView.h"

@implementation HAHashTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect labelFrame = frame;
        labelFrame.origin.x = 0;
        labelFrame.origin.y = 0;
        self.textLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.textLabel setTextColor:[UIColor HATextColor]];
        [self.textLabel setFont:STKFont(17)];
        UITapGestureRecognizer *tr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hashTagTapped:)];
        [self addGestureRecognizer:tr];
        [self addSubview:self.textLabel];
        _selected = NO;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self.textLabel setText:[NSString stringWithFormat:@"#%@", _text]];
    [self.textLabel sizeToFit];
    CGRect frame = self.frame;
    frame.size = self.textLabel.bounds.size;
    [self setFrame:frame];
}

- (void)hashTagTapped:(UIGestureRecognizer *)gr
{
    [self setSelected:![self isSelected]];
    if ([self isSelected]) {
        [self setAlpha:1.0f];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setFont:STKBoldFont(17)];
        [self.textLabel sizeToFit];
        [UIView animateWithDuration:0.5 animations:^{
            self.transform = CGAffineTransformMakeScale(1.4, 1.4);
        }];
    } else {
        [self setAnimating:YES];
        [UIView animateWithDuration:0.5 animations:^{
            [self.textLabel setTextColor:[UIColor HATextColor]];
            [self.textLabel setFont:STKFont(17)];
            [self.textLabel sizeToFit];
            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
            [self setAnimating:NO];
        }];
    }
    if (self.delegate) {
        [self.delegate hashTagTapped:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.superview];
    self.center = location;
    return;
}

- (float)randomNumberBetween:(float)min maxNumber:(float)max
{
    return min + arc4random_uniform(max - min + 1);
}

- (void)presentAndDismiss
{
    if (! [self isAnimating]) {
        [self setAnimating:YES];
        self.center = randomPointWithinContainer(self.superview.bounds.size, self.bounds.size);
        if (self.sisterTags) {
            
            [self.sisterTags enumerateKeysAndObjectsUsingBlock:^(id key, UIView *obj, BOOL *stop) {
                float angle = [self randomNumberBetween:0 maxNumber:360];
                CGPoint shiftedCenter;
                CGFloat extraSpace = 50;
                if (![key isEqualToString:self.text]) {
                while(CGRectIntersectsRect(self.frame,obj.frame))
                    {
                        CGPoint startPoint = self.center;
                        
                        shiftedCenter.x = startPoint.x - (extraSpace * cos(angle));
                        
                        if(obj.center.y < self.center.y)
                            shiftedCenter.y = startPoint.y + extraSpace * sin(angle);
                        else
                            shiftedCenter.y = startPoint.y - extraSpace * sin(angle);
                        self.center = shiftedCenter;
                        
                    }
                }
            }];
        }
        [UIView animateWithDuration:2.f animations:^{
            [self setAlpha:1.f];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (![self isSelected]) {
                    [UIView animateWithDuration:1.f animations:^{
                        [self setAlpha:0.f];
                    } completion:^(BOOL finished) {
                        [self setAnimating:NO];
                    }];
                } else {
                    [self setAnimating:NO];
                }
            });
        }];
    }
}

- (void)markSelected
{
    self.center = randomPointWithinContainer(self.superview.bounds.size, self.bounds.size);
    [self setAlpha:1.f];
    self.transform = CGAffineTransformMakeScale(1.4, 1.4);
    self.selected = YES;
    [self.textLabel setTextColor:[UIColor whiteColor]];
    [self.textLabel setFont:STKBoldFont(17)];
    [self.textLabel sizeToFit];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
