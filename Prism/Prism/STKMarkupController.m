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
#import "STKFetchDescription.h"

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
        _allowsAllUserTagging = NO;
        
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
    [[self view] setClipsToBounds:YES];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]];
    [[self view] addSubview:iv];
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [overlay setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
    [[self view] addSubview:overlay];

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
    if(![self preventsUserTagging]) {
        [[self promptLabel] setText:@"Use # to add a tag and @ to add a person"];
    } else {
        [[self promptLabel] setText:@"Use # to add a tag"];
    }
    [[self view] addSubview:[self promptLabel]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    [[self tableView] setShowsVerticalScrollIndicator:NO];
    [[self tableView] setDelegate:self];
    [[self tableView] setDataSource:self];
    [[self tableView] setScrollEnabled:YES];
    [[self tableView] setHidden:YES];
//    [[self tableView] setBackgroundColor:[UIColor clearColor]];
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
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v(==568)]-(-44)-|" options:0 metrics:nil views:@{@"v" : iv}]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v" : overlay}]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:@{@"v" : iv}]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:@{@"v" : overlay}]];

}

- (void)setPreventsUserTagging:(BOOL)preventsUserTagging
{
    _preventsUserTagging = preventsUserTagging;
    if([self preventsUserTagging]) {
        [[self promptLabel] setText:@"Use # to add a tag"];
    } else {
        [[self promptLabel] setText:@"Use # to add a tag and @ to add a person"];
    }
}

- (void)setHidesDoneButton:(BOOL)hidesDoneButton
{
    _hidesDoneButton = hidesDoneButton;
    [[self doneButton] setHidden:_hidesDoneButton];
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
    
    STKFetchDescription *fd = [[STKFetchDescription alloc] init];
    [fd setFilterDictionary:@{@"status" : STKRequestStatusAccepted}];
    [fd setDirection:STKQueryObjectPageNewer];

    [[STKUserStore store] fetchTrustsForUser:[[STKUserStore store] currentUser] fetchDescription:fd completion:^(NSArray *trusts, NSError *err) {
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
            count = (int)[[self hashTags] count];
        else
            count = (int)[[self userTags] count];
        
        if(count > 3)
            count = 3;
        
        float currentBottom = [[self view] frame].origin.y + [[self view] frame].size.height;
        float newHeight = [[self tableView] rowHeight] * count;
        
        [[self view] setFrame:CGRectMake(0, currentBottom - newHeight, 320, newHeight)];
        [[self tableView] setHidden:NO];
        [[self promptLabel] setHidden:YES];
    } else {
        float currentBottom = [[self view] frame].origin.y + [[self view] frame].size.height;
        float newHeight = 44;
        
        [[self view] setFrame:CGRectMake(0, currentBottom - newHeight, 320, newHeight)];
        
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
        [exp enumerateMatchesInString:[textView text] options:0 range:NSMakeRange(0, [[textView text] length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
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
            if(![self preventsUserTagging]) {
                if([textBasis length] > 1 ){
                    if ([self allowsAllUserTagging]) {
                        [[STKUserStore store] searchUsersWithName:textBasis completion:^(NSArray *users, NSError *err) {
                            [self setUserTags:users];
                            [self updateView];
                        }];
                    } else {
                        [[STKUserStore store] searchUserTrustsWithName:textBasis
                                                            completion:^(NSArray *users, NSError *error) {
                                                                [self setUserTags:users];
                                                                [self updateView];
                                                            }];
                    }
                    
                } else {
                    [self setUserTags:nil];
                    [self updateView];
                }
            }
        }
    } else {
        [self setHashTags:nil];
        [self setUserTags:nil];
        [self updateView];
    }

    if([self preventsUserTagging] && [self markupType] == STKMarkupTypeUser) {
        [self setMarkupRange:NSMakeRange(NSNotFound, 0)];
        [self setReplacementRange:NSMakeRange(NSNotFound, 0)];
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
        
        [[cell luminaryIcon] setHidden:![user isLuminary]];


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
