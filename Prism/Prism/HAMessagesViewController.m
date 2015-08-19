//
//  HAMessagesViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 8/14/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessagesViewController.h"
#import "HAGroupCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUser.h"
#import "STKUserStore.h"
#import "STKOrganization.h"
#import "STKOrgStatus.h"
#import "STKGroup.h"
#import "STKNavigationButton.h"
#import "HAGroupMembersViewController.h"
#import "STKMessage.h"
#import "STKNotificationBadge.h"
#import "HAMessageCell.h"
#import "HAMessageImageCell.h"
#import "STKMessageMetaData.h"
#import "STKMessageMetaDataImage.h"
#import "STKUserListViewController.h"
#import "STKWebViewController.h"
#import "HAMessageViewedController.h"
#import "HASingleMessageImageController.h"
#import "STKProfileViewController.h"
#import "STKLuminatingBar.h"
#import "HAPostMessageView.h"
#import "STKMarkupController.h"
#import "STKMarkupUtilities.h"
#import "STKProcessingView.h"
#import "HAGroupInfoViewController.h"

NSString * const HAMessageHashTagURLScheme = @"hashtag";
NSString * const HAMessageUserURLScheme = @"user";

@interface HAMessagesViewController ()<UITableViewDataSource, UITableViewDelegate, HAMessageCellDelegate, STKMarkupControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HAPostMessageViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) STKLuminatingBar *luminatingBar;

@property (nonatomic, strong) UIBarButtonItem *membersButton;
@property (nonatomic, strong) NSArray *members;
//@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) HAPostMessageView *postView;
@property (nonatomic, strong) STKMarkupController *markupController;
@property (nonatomic) CGRect originalFrameForMarkupController;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *postViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *tableViewBottomConstraint;

@property (nonatomic, getter=isUpdatingMessages) BOOL updatingMessages;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic) BOOL initialLoadComplete;
@property (nonatomic, getter=isDirectController) BOOL directController;

@property (nonatomic, strong) NSIndexPath *pendingIndex;

@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation HAMessagesViewController

- (instancetype)initWithOrganization:(STKOrganization *)organization group:(STKGroup *)group
{
    self = [super init];
    if (self) {
        _organization = organization;
        _group = group;
        NSString *groupString = group?[group.name lowercaseString]:@"all";
        self.title = [NSString stringWithFormat:@"#%@", groupString];
        [self layoutViews];
        [self layoutConstraints];
//        self.frc = [[NSFetchedResultsController alloc] init];
    }
    return self;
}

- (instancetype)initWithOrganization:(STKOrganization *)organization group:(STKGroup *)group user:(STKUser *)user
{
    self = [super init];
    if (self) {
        _organization = organization;
        _group = group;
        NSString *groupString = group?[group.name lowercaseString]:@"all";
        self.title = [NSString stringWithFormat:@"#%@", groupString];
        if (user) {
            self.title = [NSString stringWithFormat:@"@%@", user.name];
        }
        _sender = user;
        double unreadCount = user.unreadCount.doubleValue;
        double messageCount = [[NSUserDefaults standardUserDefaults] doubleForKey:HAUnreadMessagesForUserKey];
        messageCount -= unreadCount;
        if (messageCount < 0) {
            messageCount = 0;
        }
        [[NSUserDefaults standardUserDefaults] setDouble:messageCount forKey:HAUnreadMessagesForUserKey];
        user.unreadCount = @0;
        
        [[[STKUserStore store] context] save:nil];
        _directController = YES;
        [self layoutViews];
        [self layoutConstraints];
        
        //        self.frc = [[NSFetchedResultsController alloc] init];
    }
    return self;
}


#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:[HAMessageCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[HAMessageCell reuseIdentifier]];
    [self.tableView registerClass:[HAMessageImageCell class] forCellReuseIdentifier:[HAMessageImageCell reuseIdentifier]];
    [self.tableView setContentInset:UIEdgeInsetsMake(64.f, 0, 80.f, 0)];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [self.navigationItem setLeftBarButtonItem:bbi];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self fetchInitialMessages];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIButton *rbb = [UIButton buttonWithType:UIButtonTypeCustom];
    [rbb setImage:[UIImage imageNamed:@"group_bar_button"] forState:UIControlStateNormal];
    [rbb setFrame:CGRectMake(0, 0, 31, 18)];
    self.members = [[STKUserStore store] getMembersForOrganization:self.organization group:self.group];
    STKNotificationBadge *badge = [[STKNotificationBadge alloc] initWithFrame:CGRectMake(10, -10, 40, 20)];
    [badge setCount:(int)self.members.count];
    [rbb addSubview:badge];
    [rbb addTarget:self action:@selector(membersButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.membersButton = [[UIBarButtonItem alloc] initWithCustomView:rbb];
    if ([self isDirectController]) {
        [self.navigationItem setRightBarButtonItem:nil];
    } else {
        [self.navigationItem setRightBarButtonItem:self.membersButton];
    }
    if (self.group) {
        [self addTitleView:YES];
    }
    self.user = [[STKUserStore store] currentUser];
}

#pragma mark Configuration
- (void)layoutViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];
    
    self.luminatingBar = [[STKLuminatingBar alloc] init];
    [self.luminatingBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.luminatingBar];
    
    self.postView = [[HAPostMessageView alloc] init];
    [self.postView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.postView setDelegate:self];
    [self.view addSubview:self.postView];
    self.tableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
    self.postViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.postView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
    
    _markupController = [[STKMarkupController alloc] initWithDelegate:self];
    [[self view] addSubview:[[self markupController] view]];
    CGRect frame = _markupController.view.frame;
    frame.origin.y = self.postView.frame.origin.y;
    self.originalFrameForMarkupController = frame;
    _markupController.view.frame = frame;
    [_markupController.view setHidden:YES];
    [_markupController setOrganization:self.organization];
    [_markupController setGroup:self.group];
    
    [self addBackgroundImage];
    [self addBlurViewWithHeight:64.f];
}

- (void)layoutConstraints
{
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.view addConstraint:self.tableViewBottomConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[lb(==4)]" options:0 metrics:nil views:@{@"lb": self.luminatingBar}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.luminatingBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.luminatingBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self.view bringSubviewToFront:self.luminatingBar];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.postView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.f constant:46.f]];
    [self.view addConstraint:self.postViewBottomConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.postView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.postView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];

}

#pragma mark Actors

- (void)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)membersButtonTapped:(id)sender
{
    STKGroup *group = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
    HAGroupMembersViewController *gvc = [[HAGroupMembersViewController alloc] init];
    [gvc setGroup:group];
    [gvc setOrganization:self.organization];
    [self.navigationController pushViewController:gvc animated:YES];
}

#pragma mark Workers

- (void)addTitleView:(BOOL)showInfo
{
    NSString *groupName = [self.group isKindOfClass:[NSString class]]?(NSString *)self.group:[self.group name];
    NSString *titleString = [NSString stringWithFormat:@"#%@", [groupName lowercaseString]];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 157, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 137, 44)];
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    [infoButton setTintColor:[UIColor HATextColor]];
    [infoButton addTarget:self action:@selector(showOverlayView:) forControlEvents:UIControlEventTouchUpInside];
    [titleLabel setText:titleString];
    [titleLabel setFont:STKFont(22)];
    [titleLabel setTextColor:[UIColor HATextColor]];
    [titleLabel sizeToFit];
    if (titleLabel.bounds.size.width > 137) {
        CGRect frame = titleLabel.frame;
        frame.size.width = 137;
        [titleLabel setFrame:frame];
    }
    [infoButton setFrame:CGRectMake(titleLabel.bounds.size.width + 8, 16, 12, 12)];
    [container addSubview:titleLabel];
    CGFloat width = titleLabel.frame.size.width + infoButton.frame.size.width;
    CGRect frame = CGRectMake(0, 0, width, 44);
    [container setFrame:frame];
    
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOverlayView:)];
    [container addGestureRecognizer:tapRecognizer];
    [container addSubview:infoButton];
    
    [self.navigationItem setTitleView:container];
}

- (void)showOverlayView:(id)sender
{
    STKGroup *group = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
    HAGroupInfoViewController *gic = [[HAGroupInfoViewController alloc] initWithOrganization:self.organization Group:group];
    [self.navigationController pushViewController:gic animated:YES];
}


- (CGFloat)firstRowHeight {
    return [self tableView:[self tableView] heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                       inSection:0]];
}

- (void)fetchInitialMessages
{
    NSError *error = nil;
    STKUser *fetchUser = nil;
    if ([self isDirectController]) {
        fetchUser = [self sender];
    }
    self.frc = [[STKUserStore store] fetchMessagesForOrganization:self.organization group:self.group user:fetchUser completion:^(NSArray *messages, NSError *err) {
        if (err) NSLog(@"%@", err.localizedDescription);
    }];
    [self.frc setDelegate:self];
    [self.frc performFetch:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    [self.tableView reloadData];
    [self scrollToBottom:NO];
//    [[STKUserStore store] fetchMessagesForOrganization:self.organization group:self.group completion:^(NSArray *messages, NSError *err) {
//        self.messages = [messages mutableCopy];
//        [self.tableView reloadData];
//        [self scrollToBottom:NO];
//    }];
}

- (void)fetchOlder
{
    STKUser *fetchUser = nil;
    if ([self isDirectController]) {
        fetchUser = [self sender];
    }
    id sectionInfo = [self.frc.sections objectAtIndex:0];
    NSUInteger count = [sectionInfo numberOfObjects];
    if (count > 0 && ![self isUpdatingMessages]) {
        [self setUpdatingMessages:YES];
        [self.luminatingBar setLuminating:YES];
        NSIndexPath *firstVisible = [[self.tableView indexPathsForVisibleRows] firstObject];
        STKMessage *topVisibleMessage = [self.frc objectAtIndexPath:firstVisible];
     
        STKMessage *refMessage = [self.frc objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [[STKUserStore store] fetchOlderMessagesForOrganization:self.organization group:self.group user:fetchUser date:refMessage.createDate completion:^(NSArray *messages, NSError *err) {
//            if (messages && messages.count > 0) {
//                NSMutableArray *paths = [NSMutableArray array];
//                [messages enumerateObjectsUsingBlock:^(STKMessage *message, NSUInteger idx, BOOL *stop) {
//                    [paths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
//                }];
//                [self.messages insertObjects:messages atIndexes:[messages indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//                    return [obj isKindOfClass:[STKMessage class]];
//                }]];
//                [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
//                if (topVisibleMessage) {
            
//
            
//                }
//                
            
//            }
            [self.frc performFetch:nil];
            [self setUpdatingMessages:NO];
            [self.luminatingBar setLuminating:NO];
            NSIndexPath *ip  = [self.frc indexPathForObject:topVisibleMessage];
            if (![ip isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            self.pendingIndex = nil;
            }
//            self.pendingIndex = ip;
            
        }];
    }
}

- (void)fetchNewer:(BOOL)animated
{
    STKUser *fetchUser = nil;
    if ([self isDirectController]) {
        fetchUser = [self sender];
    }
    if (! [self isUpdatingMessages]) {
        [self setUpdatingMessages:YES];
        [self.luminatingBar setLuminating:YES];
        STKMessage *refMessage = nil;
        id sectionInfo = [self.frc.sections objectAtIndex:0];
        NSInteger count = [sectionInfo numberOfObjects];
        if (count > 0) {
            refMessage = [self.frc objectAtIndexPath:[NSIndexPath indexPathForRow:(count - 1) inSection:0]];
        }
        NSDate *refDate = [NSDate date];
        if (refMessage) {
            refDate = [refMessage createDate];
        }
        [[STKUserStore store] fetchLatestMessagesForOrganization:self.organization group:self.group user:fetchUser date:refDate completion:^(NSArray *messages, NSError *err) {
            [self.frc performFetch:nil];
            [self setUpdatingMessages:NO];
            [self.luminatingBar setLuminating:NO];
            [self.tableView reloadData];
            [[self luminatingBar] setLuminating:NO];
            self.updatingMessages = NO;
        }];
    }
}

- (void)scrollToBottom:(BOOL)animated
{
    id sectionInfo = [self.frc.sections objectAtIndex:0];
    NSInteger count = [sectionInfo numberOfObjects];
    if (count > 0) {
        if (count > 0) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)gr
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
//            [self.tableViewBottomConstraint setConstant:self.postView.frame.size.height];
        }
        [self.postView.textView resignFirstResponder];
        [self.postViewBottomConstraint setConstant:0];
        [self.markupController.view setFrame:self.originalFrameForMarkupController];
        [self.markupController.view setHidden:YES];
        [self.view layoutIfNeeded];
        
    }];
}

- (void)editMessageAtIndexPath:(NSIndexPath *)ip
{
    STKMessage *message = [self.frc objectAtIndexPath:ip];
    self.editingIndexPath = ip;
    self.editing = YES;
    [self.postView.textView setAttributedText:[message attributedMessageText]];
    [self.postView.textView becomeFirstResponder];
    //    [self.view addGestureRecognizer:self.viewTap];
}

- (void)deleteMessageAtIndexPath:(NSIndexPath *)ip
{
    STKMessage *message = [self.frc objectAtIndexPath:ip];
    [[STKUserStore store] deleteMessage:message completion:^(NSError *err) {
        [self.tableView endEditing:YES];
    }];
    
}


#pragma mark Cell Generation

- (UITableViewCell *)messageCell:(STKMessage *)message
{
    HAMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HAMessageCell reuseIdentifier]];
    [cell setMessage:message];
    [cell setDelegate:self];
    __block BOOL liked = NO;
    if ([message.creator.uniqueID isEqualToString:self.user.uniqueID] &&
        ([self userIsLeader] || [self.user.type isEqualToString:@"institution_verified"])) {
        [cell.viewedButton setHidden:NO];
        if (message.read.count > 1) {
            [cell.viewedLabel setHidden:NO];
        }
    }
    [message.likes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([obj isEqualToString:self.user.uniqueID]) {
                liked = YES;
            }
        } else if ([obj isKindOfClass:[STKUser class]]) {
            if ([[obj uniqueID] isEqualToString:self.user.uniqueID]) {
                liked = YES;
            }
        }
    }];
    [cell setLiked:liked];
    return cell;
}

- (UITableViewCell *)messageImageCell:(STKMessage *)message
{
    HAMessageImageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HAMessageImageCell reuseIdentifier]];
    [cell setMessage:message];
    [cell setDelegate:self];
    __block BOOL liked = NO;
    if ([message.creator.uniqueID isEqualToString:self.user.uniqueID] &&
        ([self userIsLeader] || [self.user.type isEqualToString:@"institution_verified"])) {
        [cell.viewedButton setHidden:NO];
        if (message.read.count > 1) {
            [cell.viewedLabel setHidden:NO];
        }
    }
    [message.likes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([obj isEqualToString:self.user.uniqueID]) {
                liked = YES;
            }
        } else if ([obj isKindOfClass:[STKUser class]]) {
            if ([[obj uniqueID] isEqualToString:self.user.uniqueID]) {
                liked = YES;
            }
        }
    }];
    [cell setLiked:liked];
    return cell;
}

#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static UIFont *f = nil;
    if (! f) {
        f = STKFont(14.f);
    }

    STKMessage *m  = [self.frc objectAtIndexPath:indexPath];
    if (m.imageURL) {
        return 60 + self.view.frame.size.width - 16;
    } else  {
        CGRect r = [m boundingBoxForMessageWithWidth:254.f];
        if (m.metaData.image.urlString) {
            return r.size.height + 80 + 163;
        } else {
            return r.size.height + 80;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    STKMessage *m =[self.frc objectAtIndexPath:indexPath];
    if ([m.creator.uniqueID isEqualToString:self.user.uniqueID] || [self userIsLeader] || [self userIsOwner]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"      " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self editMessageAtIndexPath:indexPath];
    }];
    float width =[moreAction.title sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0]}].width;
    width = width+40;
    float height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    UIImage *moreImage = [UIImage HAPatternImage:[UIImage imageNamed:@"edit_edit"] withHeight:height andWidth:width bgColor:[UIColor colorWithRed:142.f/255.f green:152.f/255.f blue:179.f/255.f alpha:1.f]];
    [moreAction setBackgroundColor:[UIColor colorWithPatternImage:moreImage]];
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"      "  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //        [self.objects removeObjectAtIndex:indexPath.row];
 
            [self deleteMessageAtIndexPath:indexPath];

    }];
    UIImage *deleteImage = [UIImage HAPatternImage:[UIImage imageNamed:@"edit_delete"] withHeight:height andWidth:width bgColor:[UIColor colorWithRed:221.f/255.f green:75.f/255.f blue:75.f/255.f alpha:1.f]];
    [deleteAction setBackgroundColor:[UIColor colorWithPatternImage:deleteImage]];
    
    STKMessage *m = [self.frc objectAtIndexPath:indexPath];
    if ([m.creator.uniqueID isEqualToString:self.user.uniqueID]){
        if (m.text) {
            return @[deleteAction, moreAction];
        } else {
            return @[deleteAction];
        }
    } else {
        return @[deleteAction];
    }
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing && self.editingIndexPath) {
        [self.postView.textView setText:@""];
        [self dismissKeyboard:nil];
//        [self.tableView reloadRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.editing = NO;
        //        self.editingIndexPath = nil;
    }
    
}

#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [self.frc.sections objectAtIndex:section];
    NSUInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    STKMessage *message = [self.frc objectAtIndexPath:indexPath];
    if (message.imageURL) {
        cell = [self messageImageCell:message];
    } else {
        cell = [self messageCell:message];
    }
    return cell;
}

#pragma mark Message View Cell Delegate
- (void)likeButtonTapped:(HAMessageCell *)sender
{
    NSIndexPath *ip = [self.tableView indexPathForCell:sender];
    if ([sender.message.creator.uniqueID isEqualToString:self.user.uniqueID]) {
        if (sender.message.likes.count > 0){
            STKUserListViewController *vc = [[STKUserListViewController alloc] init];
            [vc setTitle:@"Likes"];
            [vc setUsers:[sender.message.likes allObjects]];
            [self.navigationController pushViewController:vc animated:YES];
        }
        [sender setLiked:NO];
    } else {
        if ([sender isLiked]) {
            [[STKUserStore store] unlikeMessage:sender.message completion:^(STKMessage *message, NSError *err) {
                [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
            }];
        } else {
            [[STKUserStore store] likeMessage:sender.message completion:^(STKMessage *message, NSError *err) {
                
                [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
                
            }];
        }
    }
}

- (void)viewedButtonTapped:(HAMessageCell *)sender
{
    NSLog(@"Message viewed tapped");
    
    HAMessageViewedController *mvc = [[HAMessageViewedController alloc] init];
    [mvc setMessage:sender.message];
    [mvc setMembers:self.members];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)previewImageTapped:(NSURL *)url
{
    STKWebViewController *wvc = [[STKWebViewController alloc] init];
    [wvc setUrl:url];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)messageImageTapped:(STKMessage *)message
{
    HASingleMessageImageController *smc = [[HASingleMessageImageController alloc] initWithMessage:message];
    [self.navigationController pushViewController:smc animated:YES];
}

- (void)videoImageTapped:(NSURL *)url
{
    STKWebViewController *wc = [[STKWebViewController alloc] init];
    [wc setUrl:url];
    [self.navigationController presentViewController:wc animated:YES completion:nil];
}

- (void)avatarTapped:(STKUser *)user
{
    STKProfileViewController *pvc = [[STKProfileViewController alloc] init];
    [pvc setProfile:user];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange
{
    if([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"]) {
        [self previewImageTapped:url];
        //        return YES;
    } else if([[url scheme] isEqualToString:HAMessageHashTagURLScheme]) {
        NSString *groupName = url.host;
        NSSet *matches = [self.organization.groups filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", groupName]];
        __block BOOL resetAll = NO;
        STKGroup *g = nil;
        if ((matches && matches.count > 0 )|| [groupName containsString:@"all"]) {
            if (matches.count > 0) {
                g = [[matches allObjects] objectAtIndex:0];
                if ([self.user.type isEqualToString:@"institution_verified"]) {
                    resetAll = YES;
                } else {
                    [g.members enumerateObjectsUsingBlock:^(STKOrgStatus *u, BOOL *stop) {
                        if ([u.member.uniqueID isEqualToString:self.user.uniqueID]) {
                            resetAll = YES;
                            *stop = YES;
                        }
                    }];
                }
                if (resetAll){
                    self.group = g;
                }
            } else {
                resetAll = YES;
                self.group = nil;
            }
            if (resetAll) {
                self.members = nil;
            }
        }
    } else if([[url scheme] isEqualToString:HAMessageUserURLScheme]) {
        STKProfileViewController *vc = [[STKProfileViewController alloc] init];
        [vc setProfile:[[STKUserStore store] userForID:[url host]]];
        [[self navigationController] pushViewController:vc animated:YES];
    }
    return NO;
}

#pragma mark Infinite Scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    float offset = [scrollView contentOffset].y + [scrollView contentInset].bottom;
//    if(offset > 0) {
//        float t = (fabs(offset) / scrollView.contentSize.height) * 100;
//        if(t < 1)
//            t = 1;
//        [[self luminatingBar] setProgress:t];
//    } else {
        [[self luminatingBar] setProgress:0];
//    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
        if(velocity.y > 0 && [scrollView contentSize].height - [scrollView frame].size.height - 20 < targetContentOffset->y) {
            [self fetchNewer:NO];
        }
        if(velocity.y < 0 && targetContentOffset->y < 100) {
            [self fetchOlder];
        }
}

#pragma mark Post View Delegate

- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary *info  = note.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    CGFloat constant = keyboardFrame.size.height;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0 animations:^{
        [self.postViewBottomConstraint setConstant:-constant];
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            [self.tableViewBottomConstraint setConstant:-(keyboardFrame.size.height + self.postView.frame.size.height)];
        }
        [self.view layoutIfNeeded];
    }];
    CGRect r = rawFrame;
    r.origin.y -= _markupController.view.frame.size.height + self.postView.frame.size.height;
    r.origin.x = 0;
    r.size.height = _markupController.view.frame.size.height;
    r.size.width = _markupController.view.frame.size.width;
    [_markupController.view setFrame:r];
    [_markupController.view setHidden:NO];
    
}

- (void)beganEditing:(HAPostMessageView *)sender
{
    //    [self.view addGestureRecognizer:self.viewTap];
}

- (void)endEditing:(HAPostMessageView *)sender
{
    NSMutableAttributedString *text = [[self.postView.textView attributedText] mutableCopy];
    self.postView.textView.text = @"";
    [self.postView.placeholder setHidden:NO];
    
    [text enumerateAttributesInRange:NSMakeRange(0, [text length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSTextAttachment *attachment = [attrs objectForKey:NSAttachmentAttributeName];
        if(attachment) {
            NSURL *userURL = [attrs objectForKey:NSLinkAttributeName];
            if(userURL) {
                NSString *uniqueID = [userURL host];
                [text replaceCharactersInRange:range withString:[NSString stringWithFormat:@"@%@", uniqueID]];
            }
        }
    }];
    if ([self isEditing] && [self editingIndexPath]) {
        STKMessage *message = [self.frc objectAtIndexPath:self.editingIndexPath];
        message.text = [text string];
        //            [self.tableView reloadRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [STKUserStore.store editMessage:message completion:^(STKMessage *message, NSError *err) {
            [self.tableView setEditing:NO];
        
            }];
    } else {
        if ([self isDirectController]) {
            [[STKUserStore store] postMessage:text.string toUser:self.sender organization:self.organization completion:^(STKMessage *message, NSError *err) {
                if (err) {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Your message could not be posted. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    
                }
                [self.postView.textView setText:@""];
                [self fetchNewer:YES];
            }];
        } else {
            STKGroup *g = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
            [[STKUserStore store] postMessage:text.string toGroup:g organization:self.organization completion:^(STKMessage *message, NSError *err) {
                if (err) {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Your message could not be posted. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    
                }
                [self.postView.textView setText:@""];
                [self fetchNewer:YES];
            }];
        }
        [self.view layoutIfNeeded];
        //        [self.view removeGestureRecognizer:self.viewTap];
        [UIView animateWithDuration:0 animations:^{
            [self.markupController.view setFrame:self.originalFrameForMarkupController];
            [self.postViewBottomConstraint setConstant:0];
            [self.markupController.view setHidden:YES];
            [self.view layoutIfNeeded];
        }];
    }
    
}

- (void)postTextChanged:(NSString *)text
{
    [self.markupController textView:self.postView.textView updatedWithText:text];
}

- (void)addButtonTapped:(HAPostMessageView *)sender
{
    [self dismissKeyboard:nil];
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    [ipc setDelegate:self];
    [ipc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [[ipc navigationBar] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[ipc navigationBar] setTranslucent:YES];
    [self.navigationController presentViewController:ipc animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    double max = 1200;
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (img.size.width < max && img.size.height < max){
        max = img.size.width > img.size.height?img.size.width:img.size.height;
    }
    int thumbCount = max < 1200?0:2;
    double ratio = img.size.width > img.size.height?img.size.width/img.size.height:img.size.height/img.size.width;
    double width = img.size.width > img.size.height?max:max/ratio;
    double height = img.size.width> img.size.height?max/ratio:max;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [img drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setCapturedImage:resized];
    [STKProcessingView present];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"prefs:root=LOCATION_SERVICES"]];
    [[STKImageStore store] uploadImage:self.capturedImage thumbnailCount:thumbCount intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        if(err) {
            
            [STKProcessingView dismiss];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Uploading Image", @"image upload error title")
                                                         message:NSLocalizedString(@"Oops! The image you selected failed to upload. Make sure you have an internet connection and try again.", @"image upload error message")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Never mind", @"cancel button title")
                                               otherButtonTitles:NSLocalizedString(@"Try Again", @"try again button title"), nil];
            [av show];
        } else {
            if ([self isDirectController]) {
                [[STKUserStore store] postMessageImage:URLString toUser:self.sender organization:self.organization completion:^(STKMessage *message, NSError *err) {
                    [STKProcessingView dismiss];
                    [self fetchNewer:YES];
                }];
            } else {
                [[STKUserStore store] postMessageImage:URLString toGroup:self.group organization:self.organization completion:^(STKMessage *message, NSError *err) {
                    [STKProcessingView dismiss];
                    [self fetchNewer:YES];
                    
                }];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Markup Controller
- (void)markupController:(STKMarkupController *)markupController didSelectHashTag:(NSString *)hashTag forMarkerAtRange:(NSRange)range
{
    if(range.location == NSNotFound) {
        range = NSMakeRange(self.postView.textView.textStorage.length, 0);
    }
    
    [self.postView.textView.textStorage replaceCharactersInRange:range
                                                      withString:[NSString stringWithFormat:@"#%@ ", hashTag]];
    [self.postView.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                                               attributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : [UIColor HATextColor]}]];
    
    NSInteger newIndex = range.location + [hashTag length] + 2;
    [self.postView.textView setSelectedRange:NSMakeRange(newIndex, 0)];
}


- (void)markupController:(STKMarkupController *)markupController didSelectUser:(STKUser *)user forMarkerAtRange:(NSRange)range
{
    NSAttributedString *str = [STKMarkupUtilities userTagForUser:user attributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : [UIColor HATextColor]}];
    
    if(range.location == NSNotFound) {
        range = NSMakeRange([self.postView.textView.textStorage length], 0);
    }
    
    [self.postView.textView.textStorage replaceCharactersInRange:range
                                            withAttributedString:str];
    [self.postView.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                                               attributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : [UIColor HATextColor]}]];
    
    NSInteger newIndex = range.location + [str length] + 2;
    [self.postView.textView setSelectedRange:NSMakeRange(newIndex, 0)];
}

- (void)markupControllerDidFinish:(STKMarkupController *)markupController
{
    [self dismissKeyboard:nil];
    [self.postView.textView setText:@""];
    [self.postView.placeholder setHidden:NO];
    [self.postView showActionButton:NO];
    [self.markupController.view setHidden:YES];
}

#pragma mark Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    if (!self.initialLoadComplete) {
        self.initialLoadComplete = YES;
        [self scrollToBottom:NO];
    }
    if ([self pendingIndex]) {
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:self.pendingIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.pendingIndex = nil;
    }
}

@end
