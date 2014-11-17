//
//  HAInsightsViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 10/1/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAInsightsViewController.h"
#import "STKContentStore.h"
#import "STKUserStore.h"
#import "STKInsight.h"
#import "STKInsightTarget.h"
#import "STKUser.h"
#import "HAInsightCell.h"
//#import "STKInsightTargetCell.h"
#import "UIViewController+STKControllerItems.h"
#import "STKInsightTitleCellTableViewCell.h"
#import "STKInsightTextCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "STKInsightArchiveCell.h"
#import "STKWebViewController.h"
#import "STKImageSharer.h"
#import "STKResolvingImageView.h"
#import "STKProfileViewController.h"
#import "Mixpanel.h"

@interface HAInsightsViewController () <UITableViewDataSource, UITableViewDelegate, STKInsightCellDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSArray *insights;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *savedInsights;
@property (nonatomic, strong) NSArray *unreadInsights;
@property (nonatomic, weak) IBOutlet UILabel *noInsightsLabel;
@property (nonatomic, strong) HAInsightCell *transitionCell;
@property (nonatomic, strong) UIImageView *transitionImageView;

- (IBAction)selectedIndexChanged:(id)sender;

@end

@implementation HAInsightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.title = @"Insight";
    [self.noInsightsLabel setTextColor:STKTextColor];
    [self.noInsightsLabel setFont:STKFont(18)];
    [self.noInsightsLabel sizeToFit];
    self.transitionImageView = [[UIImageView alloc] init];
    [self.view addSubview:self.transitionImageView];
    [self.transitionImageView setHidden:YES];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    
    [self.tableView registerNib:[UINib nibWithNibName:[STKInsightTextCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[STKInsightTextCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[STKInsightTitleCellTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[STKInsightTitleCellTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[HAInsightCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[HAInsightCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[STKInsightArchiveCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[STKInsightArchiveCell reuseIdentifier]];
    
    if ([self isModal]) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
        [self.navigationItem setLeftBarButtonItem:bbi];
        NSMutableDictionary *props = [[[[STKUserStore store] currentUser] mixpanelProperties] mutableCopy];
        if (self.insightTarget) {
            [props setObject:self.insightTarget.insight.title forKey:@"insight_title"];
            [props setObject:self.insightTarget.insight.uniqueID forKey:@"insight_id"];
        }

        [[Mixpanel sharedInstance] track:@"Viewed Insight" properties:[props copy]];
//        UILabel *titleLabel = [[UILabel alloc] init];
//        [titleLabel setText:@"Insight"];
//        [titleLabel setFont:STKFont(22)];
//        [titleLabel setTextColor:STKTextColor];
//        [titleLabel sizeToFit];
//        [self.navigationItem setTitleView:titleLabel];
//        [self.navigationController.navigationBar setTintColor:STKTextColor];
    } else {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                                  landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(back:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
        [self.navigationItem setHidesBackButton:YES];
    }
    if (!self.insightTarget) {
        [self.segmentedControl setHidden:NO];
        [self.tableView setContentInset:UIEdgeInsetsMake(119.f, 0.f, 0, 0.f)];
        [self addBlurViewWithHeight:114.f];
        [self.view bringSubviewToFront:self.segmentedControl];
    } else {
        [self.segmentedControl setHidden:YES];
        [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0, 0, 0)];
        [self addBlurViewWithHeight:64.f];
    }
    
//    [self.tableView set]
    
}

- (void)close:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadList
{
    if (!self.insightTarget) {
        [[STKContentStore store] fetchInsightsForUser:[[STKUserStore store] currentUser] fetchDescription:nil completion:^(NSArray *insights, NSError *err) {
            self.insights = insights;
            [self filterArrays];
        }];
    }
}

- (void)filterArrays
{
    self.unreadInsights = [self.insights filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(liked == NO) && (disliked == NO)"]];
    [self.noInsightsLabel setHidden:([self.unreadInsights count] > 0 || self.segmentedControl.selectedSegmentIndex == 1) || self.insightTarget];
    [self.view bringSubviewToFront:self.noInsightsLabel];
    self.savedInsights = [self.insights filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(liked == YES)"]];
    if ([self.segmentedControl selectedSegmentIndex] == 0 || self.insightTarget) {
        [self.tableView setAllowsSelection:NO];
    } else {
        [self.tableView setAllowsSelection:YES];
    }
    [self.tableView reloadData];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.noInsightsLabel setHidden:YES];
    if (!self.insightTarget) {
        [self loadList];
    }
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.insightTarget) {
        return 1;
    }
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        return self.unreadInsights.count;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.insightTarget) {
        return 3;
    }
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        if ([self.unreadInsights count] > 0) {
            return 2;
        } else {
            return 0;
        }
    } else {
        return [self.savedInsights count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.segmentedControl selectedSegmentIndex] == 0 || self.insightTarget) {
        return [self unreadPostCellForTableView:tableView atIndexPath:indexPath];
    } else {
        return [self archiveCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (UITableViewCell *)unreadPostCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [self postCellForTableView:tableView atIndexPath:indexPath];
            break;
        case 1:
            return [self titleCellForTableView:tableView atIndexPath:indexPath];
            break;
        case 2:
            return [self textCellForTableView:tableView];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)archiveCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    STKInsightTarget *it = [self.savedInsights objectAtIndex:indexPath.row];
    NSString *class = [STKInsightArchiveCell reuseIdentifier];
    STKInsightArchiveCell *cell = [tableView dequeueReusableCellWithIdentifier:class];
    [cell setInsightTarget:it];
    return cell;
}

- (UITableViewCell *)postCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    STKInsightTarget *it = self.insightTarget?self.insightTarget:[self.unreadInsights objectAtIndex:indexPath.section];
    NSString *class = NSStringFromClass([HAInsightCell class]);
    HAInsightCell *cell = [tableView dequeueReusableCellWithIdentifier:class];
    if (self.insightTarget) {
        if (![self isModal]) {
            [cell setArchived:YES];
        } else {
            [cell setArchived:NO];
        }
        [cell setFullBleed:YES];
    } else {
        [cell setArchived:NO];
    }
    [cell setInsightTarget:it];
    [cell setDelegate:self];
    return cell;
}

- (UITableViewCell *)titleCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    STKInsightTarget *it = self.insightTarget?self.insightTarget:[self.unreadInsights objectAtIndex:indexPath.section];
    NSString *class = [STKInsightTitleCellTableViewCell reuseIdentifier];
    STKInsightTitleCellTableViewCell *tc = [tableView dequeueReusableCellWithIdentifier:class];
    [tc setInsightTarget:it];
    if (self.insightTarget) {
        [tc setFullBleed:YES];
    }
    [tc setDelegate:self];
    return tc;
}

- (void)titleControlTapped:(STKInsightTarget *)it
{
    
    if (self.insightTarget) {
        if ([self presentingViewController]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        NSInteger section = [self.unreadInsights indexOfObjectIdenticalTo:it];
        HAInsightCell *cell = (HAInsightCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        STKResolvingImageView *iv = [cell postImageView];
        UIImage *image = [iv image];
        
        CGRect posRect = [self.view convertRect:cell.postImageView.frame fromView:cell];
        [self setTransitionCell:cell];
        [[self menuController] transitionToInsightTarget:it fromRect:posRect usingImage:image inViewController:self animated:YES];
    }

}

- (UITableViewCell *)textCellForTableView:(UITableView *)tableView
{
    STKInsightTarget *it = self.insightTarget?self.insightTarget:[self.unreadInsights objectAtIndex:0];
    NSString *class = [STKInsightTextCell reuseIdentifier];
    STKInsightTextCell *cell = [tableView dequeueReusableCellWithIdentifier:class];
    [cell setInsightTarget:it];
    [cell.textView setDelegate:self];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.segmentedControl selectedSegmentIndex] == 0 || self.insightTarget) {
        switch (indexPath.row) {
            case 0:
                if (self.insightTarget){
                    return 372;
                }
                return 350;
                break;
            case 1:
                return 65;
            case 2:
                return 300;
                ;
            default:
                return 0;
                break;
        }
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STKInsightTarget *it = [self.savedInsights objectAtIndex:indexPath.row];
    HAInsightsViewController *ivc = [[HAInsightsViewController alloc] init];
    [ivc setInsightTarget:it];
    [ivc setModal:NO];
    [ivc setArchived:YES];
    [self.navigationController pushViewController:ivc animated:YES];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view;
//    UILabel *label;
//    switch (section) {
//        case 2:
//            view = [[UIView alloc] init];
//            [view setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.3]];
//            label = [[UILabel alloc] init];
//            [label setText:@"Insight"];
//            [label setFont:STKFont(16)];
//            [label setTextColor:STKTextColor];
//            [label sizeToFit];
//            [view addSubview:label];
//            [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:0 constant:1]];
//            [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:0 constant:1]];
//            return view;
//            break;
//            
//        default:
//            return nil;
//            break;
//    }
//}

- (void)likeButtonTapped:(STKInsightTarget *)it
{
    [[STKContentStore store] likeInsight:it completion:^(NSError *err) {
        NSMutableDictionary *props = [[[[STKUserStore store] currentUser] mixpanelProperties] mutableCopy];
        [props setObject:it.insight.title forKey:@"insight_title"];
        [props setObject:it.insight.uniqueID forKey:@"insight_id"];
        [[Mixpanel sharedInstance] track:@"Liked insight" properties:[props copy]];
        if ([self isModal] || [self isArchived]) {
            [[self navigationController] popViewControllerAnimated:YES];
        }
        [self filterArrays];
        
    }];
}

- (void)dislikeButtonTapped:(STKInsightTarget *)it
{
    [[STKContentStore store] dislikeInsight:it completion:^(NSError *err) {
        NSMutableDictionary *props = [[[[STKUserStore store] currentUser] mixpanelProperties] mutableCopy];
        [props setObject:it.insight.title forKey:@"insight_title"];
        [props setObject:it.insight.uniqueID forKey:@"insight_id"];
        [[Mixpanel sharedInstance] track:@"Disliked insight" properties:[props copy]];
        if ([self isModal] || [self isArchived]) {
            [[self navigationController] popViewControllerAnimated:YES];
        }
        [self filterArrays];
    }];
}

- (void)avatarImageTapped:(STKUser *)user
{
    STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
    [pvc setProfile:user];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (IBAction)selectedIndexChanged:(id)sender
{
    [self.tableView setAllowsSelection:([self.segmentedControl selectedSegmentIndex] == 1)];
    [self filterArrays];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if([[URL scheme] isEqualToString:@"http"] || [[URL scheme] isEqualToString:@"https"]) {
        NSMutableDictionary *props = [[[[STKUserStore store] currentUser] mixpanelProperties] mutableCopy];
        if (self.insightTarget) {
            [props setObject:self.insightTarget.insight.title forKey:@"insight_title"];
            [props setObject:self.insightTarget.insight.uniqueID forKey:@"insight_id"];
        }
        
        [[Mixpanel sharedInstance] track:@"Clicked insight link." properties:[props copy]];
        STKWebViewController *wvc = [[STKWebViewController alloc] init];
        [wvc setUrl:URL];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:wvc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
    return NO;
}


- (void)shareInsight:(STKInsight *)insight
{
//    STKInsight *insight = self.insightTarget?self.insightTarget.insight:[[self.unreadInsights objectAtIndex:0] insight];
    UIActivityViewController *vc = [[STKImageSharer defaultSharer] activityViewControllerForInsight:insight
                                                                                   finishHandler:^(UIDocumentInteractionController *doc) {
                                                                                       [doc presentOpenInMenuFromRect:[[self view] bounds]
                                                                                                               inView:[self view]
                                                                                                             animated:YES];
                                                                                   }];
    if(vc) {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)insightImageTapped:(HAInsightCell *)cell
{
    if (self.insightTarget) {
        if ([self presentingViewController]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        STKInsightTarget *it = [cell insightTarget];
        STKResolvingImageView *iv = cell.postImageView;
        UIImage *image = [iv image];
        
        CGRect posRect = [self.view convertRect:cell.postImageView.frame fromView:cell];
        [self setTransitionCell:cell];
//        UINavigationController *nvc = [[UINavigationController alloc] init];
//        HAInsightsViewController *ivc = [[HAInsightsViewController alloc] init];
//        
//        [ivc setInsightTarget:cell.insightTarget];
//        [ivc setModal:YES];
//        [nvc addChildViewController:ivc];
//        [nvc setModalPresentationStyle:UIModalPresentationCustom];
        [[self menuController] transitionToInsightTarget:it fromRect:posRect usingImage:image inViewController:self animated:YES];
    }
    
}

- (STKMenuController *)menuController
{
    UIViewController *parent = [self parentViewController];
    while(parent != nil) {
        if([parent isKindOfClass:[STKMenuController class]])
            return (STKMenuController *)parent;
        
        parent = [parent parentViewController];
    }
    return nil;
}


@end
