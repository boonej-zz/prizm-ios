//
//  STKHashtagToolbar.m
//  Prism
//
//  Created by Jesse Stevens Black on 11/28/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKHashtagToolbar.h"
#import "UITextView+STKHashtagDetector.h"
#import "STKUserStore.h"

@interface STKHashtagToolbar ()

@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UILabel *promptLabel;

@property (nonatomic, strong) UIToolbar *toolbar;

@end


@implementation STKHashtagToolbar

// This is to avoid _delegate ivar of Toolbar that seems to be private or unused
@synthesize delegate = delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self setBackgroundColor:[STKUnselectedColor colorWithAlphaComponent:1]];
        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [_doneButton setFrame:CGRectMake(270, 0, 50, 44)];
        [_doneButton setTintColor:[UIColor whiteColor]];
        [self addSubview:_doneButton];

        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 270, 44)];
        [_toolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
        [_toolbar setTintColor:[UIColor whiteColor]];
        [_toolbar setBackgroundColor:[UIColor clearColor]];
        [_toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [_toolbar setClipsToBounds:YES];
        [self addSubview:_toolbar];
        
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 260, 44)];
        [_promptLabel setFont:[UIFont systemFontOfSize:12]];
        [_promptLabel setNumberOfLines:2];
        [_promptLabel setTextColor:[UIColor whiteColor]];
        [_promptLabel setText:@"Use # to add a tag and @ to add a person"];
        [self addSubview:_promptLabel];
        
        [_toolbar setHidden:YES];
        
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tb(==270)][done]|" options:0 metrics:nil views:@{@"tb" : _toolbar, @"done" : _doneButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[lbl(==260)]" options:0 metrics:nil views:@{@"lbl" : _promptLabel}]];
        
        for(UIView *v in [self subviews]) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v" : v}]];
        }
    }
    return self;
}


- (void)done:(id)sender
{
    if([[self delegate] respondsToSelector:@selector(hashtagToolbarClickedDone:)]) {
        [[self delegate] hashtagToolbarClickedDone:self];
    }
}

- (void)setHashtags:(NSArray *)hashtags
{
    _hashtags = hashtags;
    if ([hashtags count] == 0)    {
        [[self toolbar] setHidden:YES];
        [[self promptLabel] setHidden:NO];
    } else {
        [[self toolbar] setHidden:NO];
        [[self promptLabel] setHidden:YES];
        NSMutableArray *items = [NSMutableArray array];

        int idx = 0;
        for (NSString *hashtag in hashtags) {
            NSString *title = [NSString stringWithFormat:@"#%@",hashtag];
            UIBarButtonItem *hashtagButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(insertHashtag:)];
            [hashtagButton setTitleTextAttributes:@{NSFontAttributeName : STKFont(12), NSForegroundColorAttributeName : [UIColor whiteColor]}
                                         forState:UIControlStateNormal];
            [hashtagButton setTag:idx];
            [items addObject:hashtagButton];
            idx ++;
        }
        [[self toolbar] setItems:items];
    }
}

- (void)insertHashtag:(id)sender
{
    if([[self delegate] respondsToSelector:@selector(hashtagToolbar:didPickHashtag:)]) {
        NSUInteger idx = [sender tag];
        [[self delegate] hashtagToolbar:self didPickHashtag:[[self hashtags] objectAtIndex:idx]];
    }
    [self setHashtags:nil];
}


@end
