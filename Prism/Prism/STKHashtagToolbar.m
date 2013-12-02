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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
        label.text = @"Type # to tag your post";
        UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:label];
        [self setItems:@[labelItem, flexibleItem, _doneButton]];
        [self setPromptButton:labelItem];
    }
    return self;
}

+ (void)attachToTextView:(UITextView *)tv withDelegate:(id <STKHashtagToolbarDelegate>)del
{
    STKHashtagToolbar *tb = [[STKHashtagToolbar alloc] init];
    [tb setDelegate:del];
    [tb setTextView:tv];
    [tv setInputAccessoryView:tb];
    [tv setDelegate:tb];
}

- (void)done:(id)sender
{
    if([[self delegate] respondsToSelector:@selector(textToolbarIsDone:)]) {
        [[self delegate] textToolbarIsDone:self];
    }
}

- (void)setHashtags:(NSArray *)hashtags
{
    _hashtags = hashtags;
    if (hashtags == nil)    {
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setItems:@[self.promptButton,flexibleItem,self.doneButton] animated:YES];
    } else {
        NSMutableArray *items = [NSMutableArray array];
        for (NSString *hashtag in hashtags) {
            NSString *title = [NSString stringWithFormat:@"#%@",hashtag];
            UIBarButtonItem *hashtagButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(insertHashtag:)];
            [items addObject:hashtagButton];
        }
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [items addObjectsFromArray:@[flexibleItem,self.doneButton]];
        [self setItems:items animated:YES];
    }
}

- (void)insertHashtag:(id)sender
{
    NSString *title = [sender title];
    NSLog(@"title %@", title);
    NSString *hashtag = [NSString stringWithFormat:@"%@ ", title];
    NSRange range = [self.textView rangeOfCurrentWord];
    NSString *captionText = self.textView.text;
    captionText = [captionText stringByReplacingCharactersInRange:range withString:hashtag];
    self.textView.text = captionText;
    [self setHashtags:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"textViewDidChange %@", textView.text);
    NSString *hashtag = [textView currentHashtag];
    if (hashtag)    {
        [[STKUserStore store] fetchRecommendedHashtags:hashtag completion:^(NSArray *hashtags, NSError *error) {
            if (error)  {
                [self setHashtags:@[hashtag]];
            } else {
                [self setHashtags:hashtags];
            }
        }];
    } else {
        [self setHashtags:nil];
    }
    [self.textView formatHashtags];
}

@end
