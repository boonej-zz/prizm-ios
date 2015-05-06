//
//  HAMessageViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 3/5/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessageViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKGroup.h"
#import "STKMessage.h"
#import "STKOrgStatus.h"
#import "STKOrganization.h"
#import "HAAvatarImageCell.h"
#import "UITableViewCell+HAExtensions.h"
#import "HAGroupCell.h"
#import "HAMessageCell.h"
#import "HAPostMessageView.h"
#import "STKNotificationBadge.h"
#import "STKMessage.h"
#import "UIImage+HACore.h"
#import "STKNavigationButton.h"
#import "HACreateGroupViewController.h"
#import "HAGroupMembersViewController.h"
#import "STKLuminatingBar.h"
#import "STKMarkupController.h"
#import "STKMarkupUtilities.h"
#import "UITextView+STKHashtagDetector.h"

@interface HAMessageViewController ()<UITableViewDataSource, UITableViewDelegate, HAMessageCellDelegate, HAPostMessageViewDelegate, UIScrollViewDelegate, STKMarkupControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet HAPostMessageView *postView;
@property (nonatomic, weak) IBOutlet STKLuminatingBar *luminatingBar;
@property (nonatomic, strong) NSArray * orgs;
@property (nonatomic, strong) NSMutableArray * groups;
@property (nonatomic, strong) NSMutableArray * messages;
@property (nonatomic, strong) STKUser * user;
@property (nonatomic, strong) id group;
@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *postViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
//@property (nonatomic, strong) UITapGestureRecognizer *viewTap;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@property (nonatomic, weak) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UILabel *overlayTitle;
@property (nonatomic, weak) IBOutlet UITextView *overlayText;
@property (nonatomic, getter=isHome) BOOL home;
@property (nonatomic, getter=isLeader) BOOL leader;
@property (nonatomic, strong) STKMarkupController *markupController;
@property (nonatomic, assign) CGRect originalFrameForMarkupController;

- (IBAction)dismissOverlayView:(id)sender;

@end

@implementation HAMessageViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self.tabBarItem setTitle:@"Message"];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"menu_message"]];
        [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"menu_message_selected"]];
    }
    return self;
}

- (id)initWithOrganization:(STKOrganization *)organization
{
    self = [super init];
    if (self) {
        self.organization = organization;
    }
    return self;
}

- (id)initWithGroup:(STKGroup *)group organization:(STKOrganization *)organization
{
    self = [super init];
    if (self) {
        self.group = group;
        self.organization = organization;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _markupController = [[STKMarkupController alloc] initWithDelegate:self];
    [[self view] addSubview:[[self markupController] view]];
    CGRect frame = _markupController.view.frame;
    frame.origin.y = self.postView.frame.origin.y;
    self.originalFrameForMarkupController = frame;
    _markupController.view.frame = frame;
    [_markupController.view setHidden:YES];
    [_markupController setOrganization:self.organization];
    STKGroup *group = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
    [_markupController setGroup:group];
    self.home = !self.organization;
    self.title = @"Message";
//    self.viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    self.postView.delegate = self;
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage HABackgroundImage]];
    iv.frame = self.view.bounds;
    [self.view insertSubview:iv atIndex:0];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    
    self.user = [[STKUserStore store] currentUser];
    NSSet *statusArray = [self.user.organizations filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[evaluatedObject status] isEqualToString:@"active"];
    }]];
    if (self.organization) {
        NSSet *leaderArray = [self.user.organizations filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [[[evaluatedObject organization] uniqueID] isEqualToString:self.organization.uniqueID] && [[evaluatedObject role] isEqualToString:@"leader"];
        }]];
        if (leaderArray.count > 0) {
            self.leader = YES;
        }
    }
    if (statusArray.count == 1) self.leader = YES;
    if (!self.organization) {
        if ([self.user.type isEqualToString:@"institution_verified"]) {
            
        } else {
            if (statusArray.count == 1) {
                
                self.organization = [[[statusArray allObjects] objectAtIndex:0] organization];
                [self setHome:YES];
                
            }
        }
    }
    if (self.organization) {
        [[STKUserStore store] fetchMembersForOrganization:self.organization completion:^(NSArray *users, NSError *err) {
            
        }];
    }
    
    UIBarButtonItem *bbi = nil;
    if (![self isHome]) {
        bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"]
                                 landscapeImagePhone:nil style:UIBarButtonItemStylePlain
                                              target:self action:@selector(back:)];
    } else {
        bbi = [self menuBarButtonItem];
    }
    
    [[self navigationItem] setLeftBarButtonItem:bbi];
    [self.navigationItem setHidesBackButton:YES];
    
    
    
    [self.tableView registerNib:[UINib nibWithNibName:[HAAvatarImageCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[HAAvatarImageCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[HAGroupCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[HAGroupCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[HAMessageCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[HAMessageCell reuseIdentifier]];
    [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0, 88.f, 0)];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addBlurViewWithHeight:64.f];
}

- (IBAction)dismissOverlayView:(id)sender
{
    [[self overlayView] setHidden:YES];
}

- (void)showOverlayView:(id)sender
{
    [[self overlayView] setHidden:NO];
}

- (void)addTitleView:(BOOL)showInfo
{
    NSString *groupName = [self.group isKindOfClass:[NSString class]]?(NSString *)self.group:[self.group name];
    NSString *titleString = [NSString stringWithFormat:@"#%@", [groupName lowercaseString]];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 157, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 137, 44)];
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [infoButton setTintColor:[UIColor HATextColor]];
//    [infoButton addTarget:self action:@selector(showOverlayView:) forControlEvents:UIControlEventTouchUpInside];
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
    if (showInfo){
        UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOverlayView:)];
        [container addGestureRecognizer:tapRecognizer];
        [container addSubview:infoButton];
    }
    [self.navigationItem setTitleView:container];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.organization && self.group) {
        [self.postView setHidden:NO];
        NSString *name = [self.group isKindOfClass:[STKGroup class]]?[[(STKGroup *)self.group name] lowercaseString ]:@"all";
        NSString *placeholder = [NSString stringWithFormat:@"Post a message to %@...", name];
        [self.postView setPlaceHolder:placeholder];
        [self fetchNewer:NO];
        STKGroup *g = [self.group isKindOfClass:[NSString class]]?nil:self.group;
        self.members = [[STKUserStore store] getMembersForOrganization:self.organization group:g];
        UIButton *rbb = [UIButton buttonWithType:UIButtonTypeCustom];
        [rbb setImage:[UIImage imageNamed:@"group_bar_button"] forState:UIControlStateNormal];
        [rbb setFrame:CGRectMake(0, 0, 31, 18)];
        STKNotificationBadge *badge = [[STKNotificationBadge alloc] initWithFrame:CGRectMake(10, -10, 40, 20)];
        [badge setCount:(int)self.members.count];
        [rbb addSubview:badge];
        [rbb addTarget:self action:@selector(membersButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithCustomView:rbb];
        [self.navigationItem  setRightBarButtonItem:bb];
        if ([self.group isKindOfClass:[STKGroup class]]) {
            [self.overlayTitle setText:[NSString stringWithFormat:@"#%@", [[self.group name] lowercaseString]]];
            [self.overlayText setText:[self.group groupDescription]];
            [self.overlayText setTextColor:[UIColor whiteColor]];
            [self.overlayText setFont:STKFont(15.f)];
            [self addTitleView:YES];
        } else {
            [self addTitleView:NO];
        }
    } else if (self.organization) {
        if (self.isHome) {
            self.title = @"Messages";
        } else {
            self.title = self.organization.name;
        }
        if ([self isLeader] || [self.user.type isEqualToString:@"institution_verified"]) {
            STKNavigationButton *view = [[STKNavigationButton alloc] init];
            [view addTarget:self action:@selector(createNewGroup:) forControlEvents:UIControlEventTouchUpInside];
            [view setOffset:9];
            
            [view setImage:[UIImage imageNamed:@"btn_addcontent"]];
            [view setHighlightedImage:[UIImage imageNamed:@"btn_addcontent_active"]];
            UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
            [self.navigationItem setRightBarButtonItem:bbi];
        }

        
        
        [self.tableViewBottomConstraint setConstant:0];
        self.groups = [[[STKUserStore store] fetchGroupsForOrganization:self.organization completion:^(NSArray *groups, NSError *err) {
            if (!err) {
                self.groups = [groups mutableCopy];
                [self.tableView reloadData];
            }
         
            
        }] mutableCopy];
        if (self.groups.count > 0) {
            [self.tableView reloadData];
        }
    } else {
        [self.tableViewBottomConstraint setConstant:0];
        self.orgs = [[STKUserStore store] fetchUserOrgs:^(NSArray *organizations, NSError *err) {
            if (!err) {
                self.orgs = organizations;
                 [self.tableView reloadData];
            }
        }];
        if (self.orgs.count > 0) {
            [self.tableView reloadData];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)fetchOlder
{
    STKGroup *g = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
    STKMessage *m = self.messages.count > 0?[self.messages objectAtIndex:0]:nil;
    if (m) {
        [[self luminatingBar] setLuminating:YES];
        [[STKUserStore store] fetchOlderMessagesForOrganization:self.organization group:g date:m.createDate completion:^(NSArray *messages, NSError *err) {
            if (messages && messages.count > 0) {
                NSMutableArray *paths = [NSMutableArray array];
                [messages enumerateObjectsUsingBlock:^(STKMessage *message, NSUInteger idx, BOOL *stop) {
                    [paths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                }];
                [self.messages insertObjects:messages atIndexes:[messages indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [obj isKindOfClass:[STKMessage class]];
                }]];
                [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
            [[self luminatingBar] setLuminating:NO];
        }];
    }
}

- (void)fetchNewer:(BOOL)scroll
{
    STKGroup *g = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
    STKMessage *m = self.messages.count > 0?[self.messages lastObject]:nil;
    [[self luminatingBar] setLuminating:YES];
    if (m) {
        [[STKUserStore store] fetchLatestMessagesForOrganization:self.organization group:g date:m.createDate completion:^(NSArray *messages, NSError *err) {
            if (messages && messages.count > 0) {
                [self.messages addObjectsFromArray:messages];
                NSMutableArray *paths = [NSMutableArray array];
                [messages enumerateObjectsUsingBlock:^(STKMessage *message, NSUInteger idx, BOOL *stop) {
                    [paths addObject:[NSIndexPath indexPathForRow:[self.messages indexOfObject:message] inSection:0]];
                }];
                [UIView animateWithDuration:0.2 animations:^{
                    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                } completion:^(BOOL finished) {
                    
                    if (scroll) {
                        [self scrollToBottom:YES];
                    }
                }];
            }
            [[self luminatingBar] setLuminating:NO];
        }];
    } else {
        self.messages = [[[STKUserStore store] fetchMessagesForOrganization:self.organization group:g completion:^(NSArray *messages, NSError *err) {
            BOOL hasMessages = self.messages.count > 0;
            if (messages.count > 0) {
            [self.messages addObjectsFromArray:messages];
                NSMutableArray *paths = [NSMutableArray array];
                [messages enumerateObjectsUsingBlock:^(STKMessage *message, NSUInteger idx, BOOL *stop) {
                    [paths addObject:[NSIndexPath indexPathForRow:[self.messages indexOfObject:message] inSection:0]];
                }];
                [UIView animateWithDuration:0.2 animations:^{
                    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                } completion:^(BOOL finished) {
                    
                        [self scrollToBottom:hasMessages];
                    
                }];
            }
            [[self luminatingBar] setLuminating:NO];
        }] mutableCopy];
        [self.tableView reloadData];
        [self scrollToBottom:NO];
    }
}

- (void)scrollToBottom:(BOOL)animated
{
    if (self.messages.count > 0) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0];
//    CGFloat scrollHeight = self.tableView.contentSize.height;
//    CGFloat viewHeight = self.tableView.frame.size.height;
//    CGFloat yOffset = scrollHeight;
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
//    if (yOffset > 0) {
////        [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:animated];
//        
//        [self.tableView scrollRectToVisible:CGRectMake(0, yOffset, self.tableView.frame.size.width, 100) animated:animated];
//    }
    }
}

- (void)editMessageAtIndexPath:(NSIndexPath *)ip
{
    STKMessage *message = [self.messages objectAtIndex:ip.row];
    self.editingIndexPath = ip;
    self.editing = YES;
    [self.postView.textView setText:message.text];
    [self.postView.textView becomeFirstResponder];
//    [self.view addGestureRecognizer:self.viewTap];
}

- (void)editGroupAtIndexPath:(NSIndexPath *)ip
{
    STKGroup *group = [self.groups objectAtIndex:(ip.row - 1)];
    HACreateGroupViewController *cgvc = [[HACreateGroupViewController alloc] initWithGroup:group];
    [self.navigationController pushViewController:cgvc animated:YES];
}

- (void)deleteMessageAtIndexPath:(NSIndexPath *)ip
{
    STKMessage *message = [self.messages objectAtIndex:ip.row];
    [[STKUserStore store] deleteMessage:message completion:^(NSError *err) {
        [self.messages removeObjectAtIndex:ip.row];
        [self.tableView endEditing:YES];
        [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
}

- (void)deleteGroupAtIndexPath:(NSIndexPath *)ip
{
    STKGroup *group = [self.groups objectAtIndex:ip.row - 1];
    [[STKUserStore store] deleteGroup:group completion:^(id data, NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"This group could not be deleted. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        } else {
            [self.groups removeObject:group];
            [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endEditing:YES];
        }
    }];
}

- (void)createNewGroup:(id)sender
{
    HACreateGroupViewController *cgvc = [[HACreateGroupViewController alloc] init];
    [cgvc setOrganization:self.organization];
    [self.navigationController pushViewController:cgvc animated:YES];
}

- (void)membersButtonTapped:(id)sender
{
    STKGroup *group = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
    HAGroupMembersViewController *gvc = [[HAGroupMembersViewController alloc] init];
    [gvc setGroup:group];
    [gvc setOrganization:self.organization];
    [self.navigationController pushViewController:gvc animated:YES];
}

#pragma mark Tableview delegate methods.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.orgs) {
        return self.orgs.count;
    } else if (self.groups) {
        return self.groups.count + 1;
    } else if (self.messages) {
        return self.messages.count;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.orgs) {
        HAAvatarImageCell *c = [self.tableView dequeueReusableCellWithIdentifier:[HAAvatarImageCell reuseIdentifier]];
        
        STKOrganization *org = [self.orgs objectAtIndex:indexPath.row];
        [c.title setText:org.name];
        [c.avatarView setUrlString:org.owner.profilePhotoPath];
        cell = c;
    } else if (self.groups){
        HAGroupCell *c = [self.tableView dequeueReusableCellWithIdentifier:[HAGroupCell reuseIdentifier]];
        NSString *text = nil;
        if (indexPath.row > 0) {
            STKGroup *group = [self.groups objectAtIndex:indexPath.row - 1];
            text = [NSString stringWithFormat:@"#%@", [group.name lowercaseString]];
        } else {
            text = @"#all";
        }
        [[c title] setText:text];
        cell = c;
    } else if (self.messages){
        STKMessage *message = [self.messages objectAtIndex:indexPath.row];
        
        HAMessageCell *c = [tableView dequeueReusableCellWithIdentifier:[HAMessageCell reuseIdentifier]];
        [c setDelegate:self];
        [c setMessage:message];
        if (message.creator == self.user) {
            [c.likeButton setEnabled:NO];
        }
        __block BOOL liked = NO;
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
        [c setLiked:liked];
        cell = c;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.messages) {
        static UIFont *f = nil;
        if (! f) {
            f = STKFont(15.f);
        }
        if (self.messages.count > 0) {
            STKMessage *m = [self.messages objectAtIndex:indexPath.row];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setAlignment:NSTextAlignmentLeft];
            CGRect r = [m.text boundingRectWithSize:CGSizeMake(254, 10000)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName : f, NSParagraphStyleAttributeName: style} context:nil];
            CGFloat height = r.size.height + 90;
            return height;
        } else {
            return 48.0f;
        }
    } else {
        return 48.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.organization && self.group) {
        return;
    }
    HAMessageViewController *mvc = nil;
    if (self.organization) {
        id group = nil;
        if (indexPath.row > 0) {
            group = [self.groups objectAtIndex:indexPath.row-1];
        } else {
            group = @"all";
        }
        mvc = [[HAMessageViewController alloc] initWithGroup:group organization:self.organization];
        
    } else {
        STKOrganization *org = [self.orgs objectAtIndex:indexPath.row];
        mvc = [[HAMessageViewController alloc] initWithOrganization:org];
    }
    [self.navigationController pushViewController:mvc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.messages) {
        if (self.messages.count > 0) {
            STKMessage *m =[self.messages objectAtIndex:indexPath.row];
            if ([m.creator.uniqueID isEqualToString:self.user.uniqueID]) {
                return YES;
            }
        }
    } else if (self.organization) {
        if (indexPath.row == 0) {
            return NO;
        }
        if ([self.user.type isEqualToString:@"institution_verified"]) {
            return YES;
        } else if ([self.user.type isEqualToString:@"user"]) {
            __block BOOL canEdit = NO;
            [self.user.organizations enumerateObjectsUsingBlock:^(STKOrgStatus *obj, BOOL *stop) {
                if ([obj.organization.uniqueID isEqualToString:self.organization.uniqueID] && [obj.role isEqualToString:@"leader"]) {
                    canEdit = YES;
                    *stop = YES;
                }
            }];
            return canEdit;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"      " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        if (self.messages) {
            [self editMessageAtIndexPath:indexPath];
        } else if (self.groups) {
            [self editGroupAtIndexPath:indexPath];
        }
    }];
    float width =[moreAction.title sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0]}].width;
    width = width+40;
    float height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    UIImage *moreImage = [UIImage HAPatternImage:[UIImage imageNamed:@"edit_edit"] withHeight:height andWidth:width bgColor:[UIColor colorWithRed:142.f/255.f green:152.f/255.f blue:179.f/255.f alpha:1.f]];
    [moreAction setBackgroundColor:[UIColor colorWithPatternImage:moreImage]];

    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"      "  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//        [self.objects removeObjectAtIndex:indexPath.row];
        if (self.messages) {
            [self deleteMessageAtIndexPath:indexPath];
        } else if (self.groups) {
            [self deleteGroupAtIndexPath:indexPath];
        }
    }];
    UIImage *deleteImage = [UIImage HAPatternImage:[UIImage imageNamed:@"edit_delete"] withHeight:height andWidth:width bgColor:[UIColor colorWithRed:221.f/255.f green:75.f/255.f blue:75.f/255.f alpha:1.f]];
    [deleteAction setBackgroundColor:[UIColor colorWithPatternImage:deleteImage]];
    
    return @[deleteAction, moreAction];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing && self.editingIndexPath) {
        [self.postView.textView setText:@""];
        [self dismissKeyboard:nil];
        [self.tableView reloadRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.editing = NO;
        self.editingIndexPath = nil;
    }
    
}




#pragma mark Message View Cell Delegate
- (void)likeButtonTapped:(HAMessageCell *)sender
{
    if ([sender isLiked]) {
        [[STKUserStore store] unlikeMessage:sender.message completion:^(STKMessage *message, NSError *err) {
            __block BOOL liked = NO;
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
            [sender setLiked:liked];
        }];
    } else {
        [[STKUserStore store] likeMessage:sender.message completion:^(STKMessage *message, NSError *err) {
            __block BOOL liked = NO;
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
            [sender setLiked:liked];
        }];
    }
}

#pragma mark Post View Delegate

- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary *info  = note.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0 animations:^{
        [self.postViewBottomConstraint setConstant:keyboardFrame.size.height];
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
        if (self.messages) {
            STKMessage *message = [self.messages objectAtIndex:self.editingIndexPath.row];
            message.text = [text string];
            [STKUserStore.store editMessage:message completion:^(STKMessage *message, NSError *err) {
                [self.tableView setEditing:NO];
            }];
        }
    } else {
        STKGroup *g = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
        [[STKUserStore store] postMessage:text.string toGroup:g organization:self.organization completion:^(STKMessage *message, NSError *err) {
            [self.postView.textView setText:@""];
            [self fetchNewer:YES];
        }];
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

- (void)dismissKeyboard:(UITapGestureRecognizer *)gr
{
        [UIView animateWithDuration:0.3 animations:^{
            [self.postView.textView resignFirstResponder];
            [self.postViewBottomConstraint setConstant:0];
            [self.markupController.view setFrame:self.originalFrameForMarkupController];
            [self.markupController.view setHidden:YES];
            [self.view layoutIfNeeded];
            
        }];
}

#pragma mark Infinite Scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offset = [scrollView contentOffset].y + [scrollView contentInset].top;
    if(offset < 0) {
        float t = fabs(offset) / 60.0;
        if(t > 1)
            t = 1;
        [[self luminatingBar] setProgress:t];
    } else {
        [[self luminatingBar] setProgress:0];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.messages) {
        if(velocity.y > 0 && [scrollView contentSize].height - [scrollView frame].size.height - 20 < targetContentOffset->y) {
            [self fetchNewer:NO];
        }
        if(velocity.y < 0 && targetContentOffset->y < 100) {
            [self fetchOlder];
        }
    }
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
    [self.markupController.view setHidden:YES];
}

@end
