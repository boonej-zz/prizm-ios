//
//  STKMarkupController.m
//  Prism
//
//  Created by Joe Conway on 5/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKMarkupController.h"
#import "STKHashtagToolbar.h"
#import "STKSearchProfileCell.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKContentStore.h"
#import "STKSearchHashTagsCell.h"

typedef enum {
    STKMarkupTypeHashtag,
    STKMarkupTypeUser
} STKMarkupType;

@interface STKMarkupController ()
    <UITableViewDataSource, UITableViewDelegate, STKHashtagToolbarDelegate>

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSRange markupRange;
@property (nonatomic) STKMarkupType markupType;
@property (nonatomic) NSRange replacementRange;

@property (nonatomic, strong) NSArray *userTags;
@property (nonatomic, strong) NSArray *hashTags;

@end

@implementation STKMarkupController

- (id)initWithDelegate:(id<STKMarkupControllerDelegate>)delegate
{
    self = [super init];
    if(self) {
        [self setDelegate:delegate];
        
        _userTags = [[NSMutableArray alloc] init];
        
        [self loadView];
    }
    return self;
}

- (void)loadView
{
    _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //[[self view] setBackgroundColor:[STKUnselectedColor colorWithAlphaComponent:1]];
    //[[self view] setBackgroundColor:[UIColor colorWithRed:0.55 green:0.6 blue:0.7 alpha:1]];
    [[self view] setBackgroundColor:[STKUnselectedColor colorWithAlphaComponent:1]];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [[self doneButton] setTitle:@"Done" forState:UIControlStateNormal];
    [[self doneButton] addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [[self doneButton] setFrame:CGRectMake(270, 0, 50, 44)];
    [[self doneButton] setTintColor:[UIColor whiteColor]];
    [[self view] addSubview:[self doneButton]];
    
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 260, 44)];
    [[self promptLabel] setFont:[UIFont systemFontOfSize:12]];
    [[self promptLabel] setNumberOfLines:2];
    [[self promptLabel] setTextColor:[UIColor whiteColor]];
    [[self promptLabel] setText:@"Use # to add a tag and @ to add a person"];
    [[self view] addSubview:[self promptLabel]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    [[self tableView] setDelegate:self];
    [[self tableView] setDataSource:self];
    [[self tableView] setScrollEnabled:YES];
    [[self tableView] setHidden:YES];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setRowHeight:44];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self view] addSubview:[self tableView]];

    for(UIView *subview in [[self view] subviews]) {
        [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v(==44)]|" options:0 metrics:nil views:@{@"v" : [self doneButton]}]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v(==44)]|" options:0 metrics:nil views:@{@"v" : [self promptLabel]}]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lbl(==260)][db]|" options:0 metrics:nil views:@{@"lbl" : [self promptLabel], @"db" : [self doneButton]}]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]-60-|" options:0 metrics:nil views:@{@"v" : [self tableView]}]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v" : [self tableView]}]];
}

- (void)reset
{
    [self setUserTags:nil];
    [self setHashTags:nil];
    [self setMarkupRange:NSMakeRange(NSNotFound, 0)];
    [self setReplacementRange:NSMakeRange(NSNotFound, 0)];
}

- (void)done:(id)sender
{
    [self reset];
    [[self delegate] markupControllerDidFinish:self];
}

- (void)displayAllUserResults
{
    [self setMarkupType:STKMarkupTypeUser];
    [[STKUserStore store] fetchTrustsForUser:[[STKUserStore store] currentUser] fetchDescription:nil completion:^(NSArray *trusts, NSError *err) {
        [self setUserTags:[trusts valueForKey:@"otherUser"]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self updateView];
        }];
    }];
}

- (void)updateView
{
    if(([[self userTags] count] > 0 && [self markupType] == STKMarkupTypeUser)
    || ([[self hashTags] count] > 0 && [self markupType] == STKMarkupTypeHashtag)) {
        [self setResultsAvailable:YES];
        [[self tableView] reloadData];
    } else {
        [self setResultsAvailable:NO];
    }
}

- (void)setResultsAvailable:(BOOL)resultsAvailable
{
    if(resultsAvailable) {
        int count = 0;
        if([self markupType] == STKMarkupTypeHashtag)
            count = [[self hashTags] count];
        else
            count = [[self userTags] count];
        
        if(count > 3)
            count = 3;
        
        [[self view] setFrame:CGRectMake(0, 0, 320, [[self tableView] rowHeight] * count)];
        [[self tableView] setHidden:NO];
        [[self promptLabel] setHidden:YES];
    } else {
        [[self view] setFrame:CGRectMake(0, 0, 320, 44)];
        [[self tableView] setHidden:YES];
        [[self promptLabel] setHidden:NO];
    }
}

- (void)textView:(UITextView *)textView updatedWithText:(NSString *)text
{
    [self setMarkupRange:NSMakeRange(NSNotFound, 0)];
    
    NSRange cursorRange = [textView selectedRange];
    if(cursorRange.length == 0) {
        // Then we are in 'cursor mode'
        NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"([#@])([A-Za-z0-9]*)"
                                                                        options:0
                                                                          error:nil];
        [exp enumerateMatchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSRange r = [result range];
            if(r.location != NSNotFound) {
                if(cursorRange.location > r.location && cursorRange.location <= r.location + r.length) {
                    NSString *markupCharacter = [[textView text] substringWithRange:[result rangeAtIndex:1]];
                    if([markupCharacter isEqualToString:@"@"]) {
                        [self setMarkupType:STKMarkupTypeUser];
                    } else {
                        [self setMarkupType:STKMarkupTypeHashtag];
                    }
                    [self setMarkupRange:[result rangeAtIndex:2]];
                    [self setReplacementRange:[result range]];
                    *stop = YES;
                }
            }
        }];
    }
    
    if ([self markupRange].location != NSNotFound) {
        NSString *textBasis = [[textView text] substringWithRange:[self markupRange]];
        if([self markupType] == STKMarkupTypeHashtag) {
            [[STKContentStore store] fetchRecommendedHashtags:textBasis completion:^(NSArray *hashtags) {
                [self setHashTags:hashtags];
                [self updateView];
            }];
        } else {
            if([textBasis length] > 1) {
                [[STKUserStore store] searchUserTrustsWithName:textBasis
                                                    completion:^(NSArray *users, NSError *error) {
                                                        [self setUserTags:users];
                                                        [self updateView];
                                                    }];
            } else {
                [self setUserTags:nil];
                [self updateView];
            }
        }
    } else {
        [self setHashTags:nil];
        [self setUserTags:nil];
        [self updateView];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self markupType] == STKMarkupTypeHashtag) {
        return [[self hashTags] count];
    }
    
    return [[self userTags] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self markupType] == STKMarkupTypeUser) {
        
        STKSearchProfileCell *cell = [STKSearchProfileCell cellForTableView:tableView target:[self tableView]];
        [[cell nameLabel] setTextColor:[UIColor whiteColor]];
        [[cell nameLabel] setFont:STKFont(14)];
        [[cell followButton] setHidden:YES];
        STKUser *user = [[self userTags] objectAtIndex:indexPath.row];
        [[cell avatarView] setUrlString:[user profilePhotoPath]];
        [[cell nameLabel] setText:[user name]];

        return cell;
    } else if([self markupType] == STKMarkupTypeHashtag) {
        
        STKSearchHashTagsCell *c = [STKSearchHashTagsCell cellForTableView:tableView target:self];
        NSString *hashTag = [[self hashTags] objectAtIndex:[indexPath row]];
        [[c hashTagLabel] setTextColor:[UIColor whiteColor]];
        [[c hashTagLabel] setText:[NSString stringWithFormat:@"#%@", hashTag]];
        [[c count] setText:@""];
        [[c contentView] setBackgroundColor:[UIColor clearColor]];
        return c;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self markupType] == STKMarkupTypeHashtag) {
        NSString *hashTag = [[self hashTags] objectAtIndex:[indexPath row]];
        [self didSelectHashTag:hashTag];
        [self setHashTags:nil];
    } else {
        STKUser *user = [[self userTags] objectAtIndex:[indexPath row]];
        [self didSelectUserTag:user];
        [self setUserTags:nil];
    }
    [self updateView];
}

- (void)didSelectHashTag:(NSString *)hashTag
{
    [[self delegate] markupController:self
                     didSelectHashTag:hashTag
                     forMarkerAtRange:[self replacementRange]];
    [self reset];
}

- (void)didSelectUserTag:(STKUser *)user
{
    [[self delegate] markupController:self
                        didSelectUser:user
                     forMarkerAtRange:[self replacementRange]];
    [self reset];
}


@end
