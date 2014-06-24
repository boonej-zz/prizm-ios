//
//  STKInviteFriendsViewController.m
//  Prism
//
//  Created by Jesse Stevens Black on 6/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInviteFriendsViewController.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKMarkupUtilities.h"
#import "STKImageSharer.h"
#import "STKPost.h"
#import "UIERealTimeBlurView.h"

NSString * const STKInviteFriendsShareText = @"Prizm app store link";

@interface STKInviteFriendsViewController ()
    <UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate, STKActivityDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;


@property (nonatomic, strong) UIImage *shareCard;
@property (nonatomic, strong) NSArray *activities;

@property (nonatomic, strong) UIActivity *continuingActivity;
@property (nonatomic, strong) UIDocumentInteractionController *documentControllerRef;

@end

@implementation STKInviteFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];

        // Custom initialization
        
        [STKMarkupUtilities imageForInviteCard:[[STKUserStore store] currentUser] withCompletion:^(UIImage *img) {
            [self setShareCard:img];
        }];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self blurView] displayLink] setPaused:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[[self blurView] displayLink] setPaused:YES];
}

- (void)setShareCard:(UIImage *)shareCard
{
    _shareCard = shareCard;
    
    STKImageSharer *sharer = [[STKImageSharer alloc] init];
    [self setActivities:[sharer activitiesForImage:shareCard title:STKInviteFriendsShareText]];

    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self tableView] setContentInset:UIEdgeInsetsMake(65, 0, 0, 0)];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"InviteCardCell"];
        if(!c) {
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteCardCell"];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:[c bounds]];
            [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [imageView setImage:[self shareCard]];
            [c addSubview:imageView];
            [c setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        return c;
    }
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
    if(!c) {
        UIActivity *activity = [self activities][[indexPath row]];
        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteCardCell"];
        [[c textLabel] setText:[activity activityTitle]];
        [[c imageView] setImage:[activity activityImage]];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return c;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return [[self activities] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 320;
    }

    return 64;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        STKActivity *activity = [self activities][[indexPath row]];
        [activity setDelegate:self];
        [activity performActivity];
    }
}

- (void)activity:(STKActivity *)activity
wantsToPresentDocumentController:(UIDocumentInteractionController *)doc
{
    [doc setDelegate:self];
    [self setContinuingActivity:activity];
    [self setDocumentControllerRef:doc];
    [doc presentOpenInMenuFromRect:[[self view] bounds]
                            inView:[self view]
                          animated:YES];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    [[self continuingActivity] activityDidFinish:YES];
    [self setContinuingActivity:nil];
    [self setDocumentControllerRef:nil];
}

@end
