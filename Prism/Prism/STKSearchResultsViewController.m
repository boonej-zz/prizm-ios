//
//  STKSearchResultsViewController.m
//  Prism
//
//  Created by Joe Conway on 4/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSearchResultsViewController.h"
#import "STKPostController.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKSearchProfileCell.h"
#import "STKTextImageCell.h"
#import "STKContentStore.h"
#import "STKTriImageCell.h"
#import "STKSearchHashTagsCell.h"
#import "STKProfileViewController.h"
#import "STKHashtagPostsViewController.h"
#import "UIERealTimeBlurView.h"

typedef enum {
    STKSearchTypeUser = 0,
    STKSearchTypeHashTag = 1
} STKSearchType;


@interface STKSearchResultsViewController ()
    <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STKPostControllerDelegate>

@property (nonatomic, strong) NSArray *filterPostOptions;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;

@property (nonatomic) STKSearchType searchType;

@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeControl;

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *filterOptionView;

@property (nonatomic, strong) NSArray *profilesFound;
@property (nonatomic, strong) NSArray *hashTagsFound;

- (IBAction)toggleFilterView:(id)sender;


@end

@implementation STKSearchResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self filterOptionView] registerNib:[UINib nibWithNibName:@"STKTextImageCell" bundle:nil]
              forCellWithReuseIdentifier:@"STKTextImageCell"];
    [[self filterOptionView] setBackgroundColor:[UIColor clearColor]];
    [[self filterOptionView] setScrollEnabled:NO];
    
    [[self searchResultsTableView] setBackgroundColor:[UIColor clearColor]];
    [[self searchResultsTableView] setSeparatorColor:STKTextTransparentColor];
    [[self searchResultsTableView] setSeparatorInset:UIEdgeInsetsMake(0, 55, 0, 0)];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [v setBackgroundColor:[UIColor clearColor]];
    [[self searchResultsTableView] setTableFooterView:v];
    
    [[self searchResultsTableView] setContentInset:UIEdgeInsetsMake(164, 0, 0, 0)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == [self searchResultsTableView])
        [[self searchTextField] resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self blurView] displayLink] setPaused:NO];
    [self reloadSearchResults];
    if([self searchType] == STKSearchTypeUser)
        [[self searchTypeControl] setSelectedSegmentIndex:0];
    else
        [[self searchTypeControl] setSelectedSegmentIndex:1];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    [[self searchTextField] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[self blurView] displayLink] setPaused:NO];

    [[self searchTextField] setText:nil];
}

- (void)toggleFollow:(id)sender atIndexPath:(NSIndexPath *)ip
{
    STKUser *u = [[self profilesFound] objectAtIndex:[ip row]];
    if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[STKUserStore store] unfollowUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self searchResultsTableView] cellForRowAtIndexPath:ip] followButton] setSelected:NO];
            }
        }];
    } else {
        [[STKUserStore store] followUser:u completion:^(id obj, NSError *err) {
            if(!err) {
                [[(STKSearchProfileCell *)[[self searchResultsTableView] cellForRowAtIndexPath:ip] followButton] setSelected:YES];
            }
        }];
    }
}

- (IBAction)searchTypeChanged:(UISegmentedControl *)sender
{
    if([sender selectedSegmentIndex] == 0) {
        [self setSearchType:STKSearchTypeUser];
    } else {
        [self setSearchType:STKSearchTypeHashTag];
    }
    
    [self setHashTagsFound:nil];
    [self setProfilesFound:nil];
    [self reloadSearchResults];
}


- (IBAction)searchFieldDidChange:(UITextField *)sender
{
    NSString *searchString = [sender text];
    if([searchString length] < 2) {
        [self reloadSearchResults];
        return;
    }
    if([self searchType] == STKSearchTypeHashTag) {
        [[STKContentStore store] searchPostsForHashtag:searchString completion:^(NSArray *hashtags, NSError *err) {
            [self setHashTagsFound:hashtags];
            [self reloadSearchResults];
        }];
    } else {
        [[STKUserStore store] searchUsersWithName:searchString completion:^(NSArray *profiles, NSError *err) {
            if(!err) {
                _profilesFound = profiles;
                [self reloadSearchResults];
            }
        }];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self setProfilesFound:nil];
    [self setHashTagsFound:nil];
    [self reloadSearchResults];
    return YES;
}

- (void)reloadSearchResults
{
    if([self searchType] == STKSearchTypeHashTag) {
        
        [[self searchResultsTableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        if([[self hashTagsFound] count] == 0) {
            [[self searchResultsTableView] setHidden:YES];
        } else {
            [[self searchResultsTableView] setHidden:NO];
        }
        
    } else {
        
        [[self searchResultsTableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        if([[self profilesFound] count] == 0) {
            [[self searchResultsTableView] setHidden:YES];
        } else {
            [[self searchResultsTableView] setHidden:NO];
        }
    }
    
    [[self searchResultsTableView] reloadData];
}

- (IBAction)toggleFilterView:(id)sender
{
    //    [[self filterOptionView] setHidden:![[self filterOptionView] isHidden]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self filterPostOptions] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[self filterPostOptions] objectAtIndex:[indexPath row]];
    STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                           forIndexPath:indexPath];
    [[cell label] setText:[item objectForKey:@"title"]];
    [[cell imageView] setImage:[item objectForKey:@"image"]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    /*   if([[[self postInfo] objectForKey:STKPostTypeKey] isEqual:[item objectForKey:STKPostTypeKey]]) {
     [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
     }
     */
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self searchType] == STKSearchTypeHashTag)
        return [[self hashTagsFound] count];
    
    return [[self profilesFound] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self searchType] == STKSearchTypeHashTag){
        STKSearchHashTagsCell *c = [STKSearchHashTagsCell cellForTableView:tableView target:self];
        NSDictionary *hashtag = [[self hashTagsFound] objectAtIndex:[indexPath row]];
        [[c hashTagLabel] setText:[NSString stringWithFormat:@"#%@",[hashtag objectForKey:@"hash_tag"]]];
        [[c count] setText:[NSString stringWithFormat:@"%@",[hashtag objectForKey:@"count"]]];
        [c setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return c;
    }
    
    STKSearchProfileCell *c = [STKSearchProfileCell cellForTableView:tableView target:self];
    STKUser *u = [[self profilesFound] objectAtIndex:[indexPath row]];
    [[c nameLabel] setTextColor:STKTextColor];
    [[c nameLabel] setText:[u name]];
    [[c avatarView] setUrlString:[u profilePhotoPath]];
    
    if([u isEqual:[[STKUserStore store] currentUser]]) {
        [[c followButton] setHidden:YES];
    } else {
        [[c followButton] setHidden:NO];
        if([u isFollowedByUser:[[STKUserStore store] currentUser]]) {
            [[c followButton] setSelected:YES];
        } else {
            [[c followButton] setSelected:NO];
        }
    }
    
    
    return c;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == [self searchResultsTableView]) {
        if([self searchType] == STKSearchTypeUser){
            STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
            [pvc setProfile:[[self profilesFound] objectAtIndex:[indexPath row]]];
            [[[self parentViewController] navigationController] pushViewController:pvc animated:YES];
        }
        
        if([self searchType] == STKSearchTypeHashTag) {
            NSDictionary *hashtag = [[self hashTagsFound] objectAtIndex:[indexPath row]];
            NSString *tag = [hashtag objectForKey:@"hash_tag"];
            if(tag) {
                STKHashtagPostsViewController *vc = [[STKHashtagPostsViewController alloc] initWithHashTag:tag];
                [[self navigationController] pushViewController:vc animated:YES];
            }
        }
    }
}



@end
