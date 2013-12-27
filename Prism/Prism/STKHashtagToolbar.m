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
    <UITextViewDelegate>
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, strong) UIBarButtonItem *promptButton;
@end


@implementation STKHashtagToolbar

// This is to avoid _delegate ivar of Toolbar that seems to be private or unused
@synthesize delegate = delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setNumberOfLines:2];
        label.text = @"Use # to add a tag and @ to add a person";
        [label sizeToFit];
        
        UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:label];
        [self setItems:@[labelItem, flexibleItem, _doneButton]];
        [self setPromptButton:labelItem];
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
    if (hashtags == nil)    {
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setItems:@[self.promptButton,flexibleItem,self.doneButton]];
    } else {
        NSMutableArray *items = [NSMutableArray array];
        int idx = 0;
        for (NSString *hashtag in hashtags) {
            NSString *title = [NSString stringWithFormat:@"#%@",hashtag];
            UIBarButtonItem *hashtagButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(insertHashtag:)];
            [hashtagButton setTag:idx];
            [items addObject:hashtagButton];
            idx ++;
        }
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [items addObjectsFromArray:@[flexibleItem,self.doneButton]];
        [self setItems:items];
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
