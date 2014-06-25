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

@import Social;
@import MessageUI;

NSString * const STKInviteFriendsShareText = @"Prizm app store link";
NSString * const STKInviteFriendsEmailSubject = @"Find me on Prizm";

@interface STKInviteFriendsViewController ()
    <UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate,
    MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;


@property (nonatomic, strong) UIImage *shareCard;
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) NSArray *availableServiceTypes;
@property (nonatomic, strong) NSArray *emailServiceArray;
@property (nonatomic, strong) NSArray *messageServiceArray;

@property (nonatomic, strong) STKImageSharer *imageSharer;

// grab the navigationbarbackround image so we can customize and restore navigation bar
@property (nonatomic, strong) UIImage *navigationBackgroundImage;
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
    
    NSMutableArray *serviceTypes = [NSMutableArray array];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [serviceTypes addObject:SLServiceTypeFacebook];
    }
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        [serviceTypes addObject:SLServiceTypeTwitter];
    }
    if ([MFMailComposeViewController canSendMail]) {
        [self setEmailServiceArray:@[@"Email"]];
    }
    if ([MFMessageComposeViewController canSendAttachments]) {
        [self setMessageServiceArray:@[@"Message"]];
    }
    
    [self setAvailableServiceTypes:serviceTypes];
    [self configureInterface];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[[self blurView] displayLink] setPaused:YES];
}

- (void)setShareCard:(UIImage *)shareCard
{
    _shareCard = shareCard;
    
    [self setImageSharer:[[STKImageSharer alloc] init]];
    
    [self setActivities:[[self imageSharer] activitiesForImage:shareCard title:STKInviteFriendsShareText viewController:self]];

    [self configureInterface];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self tableView] setContentInset:UIEdgeInsetsMake(65, 0, 0, 0)];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]]];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self tableView] setSeparatorColor:STKTextTransparentColor];
}

- (void)configureInterface
{
    [[self tableView] reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"InviteCardCell"];
        if(!c) {
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteCardCell"];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[c bounds]];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [imageView setImage:[self shareCard]];
        [c addSubview:imageView];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];

        return c;
    }
    UITableViewCell *c;

    if ([indexPath section] == 1) {
        c = [tableView dequeueReusableCellWithIdentifier:@"SocialTypeCell"];
        if(!c) {
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SocialTypeCell"];
        }
        NSString *serviceType = [self availableServiceTypes][[indexPath row]];
        [[c textLabel] setText:serviceType];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if ([indexPath section] == 2) {
        c = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
        if(!c) {
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActivityCell"];
        }
        UIActivity *activity = [self activities][[indexPath row]];
        [[c textLabel] setText:[activity activityTitle]];
        [[c imageView] setImage:[activity activityImage]];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if ([indexPath section] == 3) {
        c = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        if(!c) {
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCell"];
        }
        [[c textLabel] setText:[[self messageServiceArray] firstObject]];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if ([indexPath section] == 4) {
        c = [tableView dequeueReusableCellWithIdentifier:@"EmailCell"];
        if(!c) {
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmailCell"];
        }
        [[c textLabel] setText:[[self emailServiceArray] firstObject]];
        [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    UIImageView *iv = [c imageView];
    CGPoint center = [iv center];
    CGRect frame = [iv frame];
    frame.size = CGSizeMake(43, 43);
    [iv setFrame:frame];
    [iv setCenter:center];
    
    return c;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return [[self availableServiceTypes] count];
    }
    if (section == 2) {
        return [[self activities] count];
    }
    if (section == 3) {
        return [[self messageServiceArray] count];
    }
    return [[self emailServiceArray] count];
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
        NSString *serviceType = [self availableServiceTypes][[indexPath row]];
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [vc setInitialText:STKInviteFriendsShareText];
        [vc addImage:[self shareCard]];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if ([indexPath section] == 2) {
        UIActivity *activity = [self activities][[indexPath row]];
        [activity performActivity];
    }
    
    if ([indexPath section] == 3) {
        [self setNavigationBackgroundImage:[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]];
        [[UINavigationBar appearance] setBackgroundImage:nil
                                           forBarMetrics:UIBarMetricsDefault];
        
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        [vc setMessageComposeDelegate:self];
        [vc setBody:STKInviteFriendsShareText];
        [vc addAttachmentData:UIImageJPEGRepresentation([self shareCard], 1.0) typeIdentifier:@"public.data" filename:@"prizm-share-card.jpeg"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    if ([indexPath section] == 4) {
        [self setNavigationBackgroundImage:[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];

        
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        [vc setMailComposeDelegate:self];
        [vc setSubject:STKInviteFriendsEmailSubject];
        [vc setMessageBody:STKInviteFriendsShareText isHTML:NO];
        [vc addAttachmentData:UIImageJPEGRepresentation([self shareCard], 1.0) mimeType:@"public.data" fileName:@"prizm-share-card.jpeg"];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setBackgroundColor:nil];
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setBackgroundColor:nil];
    }];
}

@end
