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

@interface HAMessageViewController ()<UITableViewDataSource, UITableViewDelegate, HAMessageCellDelegate, HAPostMessageViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet HAPostMessageView *postView;
@property (nonatomic, strong) NSArray * orgs;
@property (nonatomic, strong) NSArray * groups;
@property (nonatomic, strong) NSMutableArray * messages;
@property (nonatomic, strong) STKUser * user;
@property (nonatomic, strong) id group;
@property (nonatomic, strong) STKOrganization *organization;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *postViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (nonatomic, strong) UITapGestureRecognizer *viewTap;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@property (nonatomic, weak) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UILabel *overlayTitle;
@property (nonatomic, weak) IBOutlet UITextView *overlayText;
@property (nonatomic, getter=isHome) BOOL home;
@property (nonatomic, getter=isLeader) BOOL leader;

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
    self.home = !self.organization;
    self.title = @"Message";
    self.viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
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
    [self.tableView setContentInset:UIEdgeInsetsMake(65.f, 0, 0, 0)];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)]];
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
    if (showInfo){
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
        [self fetchNewer];
        STKGroup *g = [self.group isKindOfClass:[NSString class]]?nil:self.group;
        self.members = [[STKUserStore store] getMembersForOrganization:self.organization group:g];
        UIButton *rbb = [UIButton buttonWithType:UIButtonTypeCustom];
        [rbb setImage:[UIImage imageNamed:@"group_bar_button"] forState:UIControlStateNormal];
        [rbb setFrame:CGRectMake(0, 0, 31, 18)];
        STKNotificationBadge *badge = [[STKNotificationBadge alloc] initWithFrame:CGRectMake(10, -10, 40, 20)];
        [badge setCount:(int)self.members.count];
        [rbb addSubview:badge];
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
        if ([self isLeader]) {
            STKNavigationButton *view = [[STKNavigationButton alloc] init];
            [view addTarget:self action:@selector(createNewGroup:) forControlEvents:UIControlEventTouchUpInside];
            [view setOffset:9];
            
            [view setImage:[UIImage imageNamed:@"btn_addcontent"]];
            [view setHighlightedImage:[UIImage imageNamed:@"btn_addcontent_active"]];
            UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:view];
            [self.navigationItem setRightBarButtonItem:bbi];
        }

        
        
        [self.tableViewBottomConstraint setConstant:0];
        [[STKUserStore store] fetchGroupsForOrganization:self.organization completion:^(NSArray *groups, NSError *err) {
            self.groups = groups;
         
                [self.tableView reloadData];
        }];
    } else {
        [self.tableViewBottomConstraint setConstant:0];
        [[STKUserStore store] fetchUserOrgs:^(NSArray *organizations, NSError *err) {
            self.orgs = organizations;
          
                 [self.tableView reloadData];
        
           
        }];
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

- (void)fetchNewer
{
    STKGroup *g = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
    STKMessage *m = self.messages.count > 0?[self.messages objectAtIndex:0]:nil;
    if (m) {
        [[STKUserStore store] fetchLatestMessagesForOrganization:self.organization group:g date:m.createDate completion:^(NSArray *messages, NSError *err) {
            if (messages) {
                NSLog(@"%lu messages found.", (long unsigned)messages.count);
                NSIndexSet *is = [messages indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [obj isKindOfClass:[STKMessage class]];
                }];
                [self.messages insertObjects:messages atIndexes:is];
                NSMutableArray *paths = [NSMutableArray array];
                [is enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [paths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                }];
            
                    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
         
                
            }
        }];
    } else {
        [[STKUserStore store] fetchMessagesForOrganization:self.organization group:g completion:^(NSArray *messages, NSError *err) {
     
            self.messages = [messages mutableCopy];
                [self.tableView reloadData];
      
            
        }];
    }
}

- (void)editMessageAtIndexPath:(NSIndexPath *)ip
{
    STKMessage *message = [self.messages objectAtIndex:ip.row];
    self.editingIndexPath = ip;
    self.editing = YES;
    [self.postView.textField setText:message.text];
    [self.postView.textField becomeFirstResponder];
    [self.view addGestureRecognizer:self.viewTap];
}

- (void)deleteMessageAtIndexPath:(NSIndexPath *)ip
{
    STKMessage *message = [self.messages objectAtIndex:ip.row];
    [STKUserStore.store deleteMessage:message completion:^(NSError *err) {
        [self.messages removeObjectAtIndex:ip.row];
        [self.tableView endEditing:YES];
        [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
}

- (void)createNewGroup:(id)sender
{
    HACreateGroupViewController *cgvc = [[HACreateGroupViewController alloc] init];
    [cgvc setOrganization:self.organization];
    [self.navigationController pushViewController:cgvc animated:YES];
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
        [c.avatarView setUrlString:org.logoURL];
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
        STKMessage *m =[self.messages objectAtIndex:indexPath.row];
        if ([m.creator.uniqueID isEqualToString:self.user.uniqueID]) {
            return YES;
        }
    } else if (self.organization) {
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"      " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        if (self.messages) {
            [self editMessageAtIndexPath:indexPath];
        }
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
    
    return @[deleteAction, moreAction];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing && self.editingIndexPath) {
        [self.postView.textField setText:@""];
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
        [self.tableViewBottomConstraint setConstant:self.tableViewBottomConstraint.constant + keyboardFrame.size.height];
        [self.view layoutIfNeeded];
    }];
    
    
}

- (void)beganEditing:(HAPostMessageView *)sender
{
    [self.view addGestureRecognizer:self.viewTap];
}

- (void)endEditing:(HAPostMessageView *)sender
{
    if ([self isEditing] && [self editingIndexPath]) {
        if (self.messages) {
            STKMessage *message = [self.messages objectAtIndex:self.editingIndexPath.row];
            message.text = self.postView.textField.text;
            [STKUserStore.store editMessage:message completion:^(STKMessage *message, NSError *err) {
                [self.tableView setEditing:NO];
            }];
        }
    } else {
        STKGroup *g = [self.group isKindOfClass:[STKGroup class]]?self.group:nil;
        [[STKUserStore store] postMessage:self.postView.textField.text toGroup:g organization:self.organization completion:^(STKMessage *message, NSError *err) {
            [self.postView.textField setText:@""];
            [self fetchNewer];
        }];
        [self.view layoutIfNeeded];
        [self.view removeGestureRecognizer:self.viewTap];
        [UIView animateWithDuration:0 animations:^{
            [self.postViewBottomConstraint setConstant:0];
            [self.tableViewBottomConstraint setConstant:46];
            [self.view layoutIfNeeded];
        }];
    }

}

- (void)dismissKeyboard:(UIGestureRecognizer *)gr
{
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.postView.textField resignFirstResponder];
        [self.postViewBottomConstraint setConstant:0];
        [self.tableViewBottomConstraint setConstant:46];
        [self.view layoutIfNeeded];
        
    }];
}

@end
