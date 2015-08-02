//
//  HAConsentViewController.m
//  Prizm
//
//  Created by Jonathan Boone on 7/31/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAConsentViewController.h"
#import "UIViewController+STKControllerItems.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "HAInterestsViewController.h"
#import "HANavigationController.h"
#import "STKTextFieldCell.h"


@interface HAConsentViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headingLabel;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UITextField *firstNameField;
@property (nonatomic, strong) UITextField *lastNameField;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UIView *wrap1;
@property (nonatomic, strong) UIView *wrap2;
@property (nonatomic, strong) UIView *wrap3;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSLayoutConstraint *scrollViewMarginBottom;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@end

@implementation HAConsentViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.values = [@{@"first": @"", @"last":@"", @"email":@""} mutableCopy];
        [self setupViews];
        [self addConstraints];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundImage];
    // Do any additional setup after loading the view.
    self.title = @"Consent";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"header"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"message"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"button"];
    [self.tableView setAllowsSelection:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
//    [NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name: object:<#(id)#>
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] init];
        [_toolbar setTranslucent:YES];
//        [_toolbar setBarStyle:UIBarStyleDefault];
//        [_toolbar setBarTintColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
        CGRect frame = self.view.frame;
        frame.size.height = 44;
        [_toolbar setFrame:frame];
        UIBarButtonItem *db = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneTapped:)];
//        [db setTitleTextAttributes:@{NSFontAttributeName:STKFont(14)} forState:UIControlStateNormal];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousTapped:)];
//        [prev setTitleTextAttributes:@{NSFontAttributeName:STKFont(14)} forState:UIControlStateNormal];
        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextTapped:)];
        [_toolbar setItems:@[db, flex, prev, next]];
//        [next setTitleTextAttributes:@{NSFontAttributeName:STKFont(14)} forState:UIControlStateNormal];
    }
    return  _toolbar;
}

- (void)nextTapped:(id)sender
{
    int row = (int)[[self editingIndexPath] row] + 1;
    if(row >= 3)
        row = 0;
    
    [self setEditingIndexPath:[NSIndexPath indexPathForRow:row inSection:2]];
    UITableViewCell *c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    if(!c) {
        [[self tableView] scrollToRowAtIndexPath:[self editingIndexPath]
                                atScrollPosition:UITableViewScrollPositionNone
                                        animated:NO];
        c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    }
    if([c respondsToSelector:@selector(textField)]) {
        if([[(STKTextFieldCell *)c textField] canBecomeFirstResponder]) {
            [[(STKTextFieldCell *)c textField] becomeFirstResponder];
        } else {
            [self nextTapped:nil];
        }
    } else {
        [self nextTapped:nil];
    }
}

- (void)doneTapped:(id)sender
{
    [[self view] endEditing:YES];
}

- (IBAction)previousTapped:(id)sender
{
    int row = (int)[[self editingIndexPath] row] - 1;
    if(row < 0)
        row = 2;
    
    [self setEditingIndexPath:[NSIndexPath indexPathForRow:row
                                                 inSection:2]];
    UITableViewCell *c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    if(!c) {
        [[self tableView] scrollToRowAtIndexPath:[self editingIndexPath]
                                atScrollPosition:UITableViewScrollPositionNone
                                        animated:NO];
        c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    }
    if([c respondsToSelector:@selector(textField)]) {
        [[(STKTextFieldCell *)c textField] becomeFirstResponder];
    } else {
        [self previousTapped:nil];
    }
}

- (void)setupViews
{
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.tableView];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
//    self.scrollView = [[UIScrollView alloc] init];
//    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view addSubview:self.scrollView];
//    NSString *message = @"Looks like you're under 13. In order to use Prizm we'll need to notify a parent that you signed up.";
//    self.headingLabel = [[UILabel alloc] init];
//    [self.headingLabel setText:@"We need your parent's information!"];
//    [self.headingLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.headingLabel setFont:STKBoldFont(18)];
//    [self.headingLabel setTextColor:[UIColor HALightTextColor]];
//    [self.headingLabel setTextAlignment:NSTextAlignmentCenter];
//    [self.scrollView addSubview:self.headingLabel];
//    self.messageTextView = [[UITextView alloc] init];
//    [self.messageTextView setText:message];
//    [self.messageTextView setEditable:NO];
//    [self.messageTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.messageTextView setFont:STKFont(14)];
//    [self.messageTextView setTextColor:[UIColor HALightTextColor]];
//    [self.messageTextView setBackgroundColor:[UIColor clearColor]];
//    [self.messageTextView setTextAlignment:NSTextAlignmentCenter];
//    [self.scrollView addSubview:self.messageTextView];
//    self.wrap1 = [[UIView alloc] init];
//    [self.wrap1 setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
//    [self.wrap1 setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.scrollView addSubview:self.wrap1];
//    self.wrap2 = [[UIView alloc] init];
//    [self.wrap2 setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
//    [self.wrap2 setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.scrollView addSubview:self.wrap2];
//    self.wrap3 = [[UIView alloc] init];
//    [self.wrap3 setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
//    [self.wrap3 setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.scrollView addSubview:self.wrap3];
//    [self.scrollView setContentSize:self.view.frame.size];
//    self.firstNameField = [[UITextField alloc] init];
//    [self.firstNameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
//    [self.firstNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.firstNameField setBackgroundColor:[UIColor clearColor]];
//    [self.firstNameField setFont:STKFont(15)];
//    [self.firstNameField setTextColor:[UIColor HATextColor]];
//    [self.firstNameField setReturnKeyType:UIReturnKeyDone];
////    [self.firstNameField setInputAccessoryView:[self toolbar]];
//    [self.firstNameField setDelegate:self];
//
//    [self.wrap1 addSubview:self.firstNameField];
//    self.lastNameField = [[UITextField alloc] init];
//    [self.lastNameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
//    [self.lastNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.lastNameField setBackgroundColor:[UIColor clearColor]];
//    [self.lastNameField setFont:STKFont(15)];
//    [self.lastNameField setTextColor:[UIColor HATextColor]];
//    [self.lastNameField setReturnKeyType:UIReturnKeyDone];
//    [self.lastNameField setDelegate:self];
////    [self.lastNameField setInputAccessoryView:[self toolbar]];
//    [self.wrap2 addSubview:self.lastNameField];
//    self.emailField = [[UITextField alloc] init];
//    [self.emailField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
//    [self.emailField setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.emailField setBackgroundColor:[UIColor clearColor]];
//    [self.emailField setFont:STKFont(15)];
//    [self.emailField setTextColor:[UIColor HATextColor]];
//    [self.emailField setReturnKeyType:UIReturnKeyDone];
//    [self.emailField setKeyboardType:UIKeyboardTypeEmailAddress];
//    [self.emailField setDelegate:self];
////    [self.emailField setInputAccessoryView:[self toolbar]];
//    [self.wrap3 addSubview:self.emailField];
//    self.nextButton = [[UIButton alloc] init];
//    [self.nextButton setTitle:@"Submit" forState:UIControlStateNormal];
//    [self.nextButton setEnabled:NO];
//    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"btn_lg"] forState:UIControlStateNormal];
//    [self.nextButton setTitleColor:[UIColor HATextColor] forState:UIControlStateNormal];
////    [self.nextButton setTitleColor:[UIColor colorWithWhite:1.f alpha:0.1] forState:UIControlStateDisabled];
//    [self.nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.nextButton.titleLabel setFont:STKBoldFont(13)];
//    [self.scrollView addSubview:self.nextButton];
}

- (void)addConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:0 metrics:nil views:@{@"tv": self.tableView}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[sv]-0-|" options:0 metrics:nil views:@{@"sv": self.scrollView}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sv]-0-|" options:0 metrics:nil views:@{@"sv": self.scrollView}]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-98-[hl]-22-[mt(==60)]-34-[w1(==46)]-1-[w2(==46)]-1-[w3(==46)]-107-[nb(==46)]" options:0 metrics:nil views:@{@"hl": self.headingLabel, @"mt": self.messageTextView, @"w1": self.wrap1, @"w2": self.wrap2, @"w3": self.wrap3, @"nb": self.nextButton}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[hl]-8-|" options:0 metrics:nil views:@{@"hl": self.headingLabel}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[mt]-40-|" options:0 metrics:nil views:@{@"mt": self.messageTextView}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[w1]-0-|" options:0 metrics:nil views:@{@"w1": self.wrap1}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[w2]-0-|" options:0 metrics:nil views:@{@"w2": self.wrap2}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[w3]-0-|" options:0 metrics:nil views:@{@"w3": self.wrap3}]];
//    [self.wrap1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[fn]-16-|" options:0 metrics:nil views:@{@"fn": self.firstNameField}]];
//    [self.wrap1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[fn]-0-|" options:0 metrics:nil views:@{@"fn": self.firstNameField}]];
//    [self.wrap2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[ln]-16-|" options:0 metrics:nil views:@{@"ln": self.lastNameField}]];
//    [self.wrap2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[ln]-0-|" options:0 metrics:nil views:@{@"ln": self.lastNameField}]];
//    [self.wrap3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[em]-16-|" options:0 metrics:nil views:@{@"em": self.emailField}]];
//    [self.wrap3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[em]-0-|" options:0 metrics:nil views:@{@"em": self.emailField}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-84-[nb]-84-|" options:0 metrics:nil views:@{@"nb": self.nextButton}]];
//    self.scrollViewMarginBottom = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
//    [self.view addConstraint:self.scrollViewMarginBottom];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)nextButtonTapped:(UIButton *)sender {
    if ([[self.values objectForKey:@"first"] isEqualToString:@""]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"You must enter a parent's name to use Prizm." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    } else if ([[self.values objectForKey:@"last"] isEqualToString:@""]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"You must enter a parent's name to use Prizm." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    } else if ([[self.values objectForKey:@"email"] isEqualToString:@""]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"You must enter a parent's email to use Prizm." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    } else {
    __block UIViewController *menuController = [self presentingViewController];
        [[STKUserStore store] submitParentConsent:self.values forUser:self.user completion:^(STKUser *user, NSError *err) {
            [self dismissViewControllerAnimated:NO completion:^{
                HAInterestsViewController *ivc = [[HAInterestsViewController alloc] init];
                [ivc setUser:self.user];
                HANavigationController *nvc = [[HANavigationController alloc] init];
                [nvc addChildViewController:ivc];
                [menuController presentViewController:nvc animated:NO completion:nil];
            }];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
//    return NO;
    return NO;
}

- (void)keyboardWillShow:(NSNotification *)note {
//    NSDictionary *info  = note.userInfo;
//    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
//    
//    CGRect rawFrame      = [value CGRectValue];
//    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
//    [self.view layoutIfNeeded];
//    [UIView animateWithDuration:0 animations:^{
//        [self.scrollViewMarginBottom setConstant:keyboardFrame.size.height];
//        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
//            [self.scrollViewMarginBottom setConstant:(keyboardFrame.size.height)];
//        }
//        [self.view layoutIfNeeded];
//    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self headerCell];
    } else if (indexPath.section == 1) {
        return [self messageCell];
    } else if (indexPath.section == 3) {
        return [self buttonCell];
    } else {
        STKTextFieldCell *cell = [STKTextFieldCell cellForTableView:tableView target:self];
        [cell setBackgroundColor:[UIColor clearColor]];
        if (indexPath.row == 0) {
            [cell.label setText:@"First Name"];
            [cell.textField setText:[self.values objectForKey:@"first"]];
        } else if (indexPath.row == 1) {
            [cell.label setText:@"Last Name"];
            [cell.textField setText:[self.values objectForKey:@"last"]];
        } else {
            [cell.label setText:@"Email"];
            [cell.textField setText:[self.values objectForKey:@"email"]];
        }
        [cell.textField setInputAccessoryView:[self toolbar]];
        [cell.inputAccessoryView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.4f]];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 64;
    } else if (indexPath.section == 1){
        return 98;
    } else if (indexPath.section == 3) {
        return 154;
    } else {
        return 46;
    }
}

- (UITableViewCell *)headerCell {
    UITableViewCell *header = [self.tableView dequeueReusableCellWithIdentifier:@"header"];
    [header setBackgroundColor:[UIColor clearColor]];
    UILabel *label = [[UILabel alloc] init];
    [label setText:@"We need your parent's information!"];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setFont:STKBoldFont(18)];
    [label setTextColor:[UIColor HALightTextColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [header addSubview:label];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[hl]-0-|" options:0 metrics:nil views:@{@"hl": label}]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[hl]-0-|" options:0 metrics:nil views:@{@"hl": label}]];
    return header;
}

- (UITableViewCell *)messageCell {
    UITableViewCell *message = [self.tableView dequeueReusableCellWithIdentifier:@"message"];
    [message setBackgroundColor:[UIColor clearColor]];
    UITextView *label = [[UITextView alloc] init];
    [label setText:@"Looks like you're under 13. In order to use Prizm we'll need to notify a parent that you signed up."];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setEditable:NO];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setFont:STKFont(14)];
    [label setScrollEnabled:NO];
    [label setTextColor:[UIColor HALightTextColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [message addSubview:label];
    [message addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[hl]-0-|" options:0 metrics:nil views:@{@"hl": label}]];
    [message addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[hl]-40-|" options:0 metrics:nil views:@{@"hl": label}]];
    return message;
}

- (UITableViewCell *)buttonCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"button"];
  
    [cell setBackgroundColor:[UIColor clearColor]];
    UIButton *done = [[UIButton alloc] init];
    [done setTranslatesAutoresizingMaskIntoConstraints:NO];
    [done setTitle:@"Submit" forState:UIControlStateNormal];
//    [done setEnabled:NO];
    [done setBackgroundImage:[UIImage imageNamed:@"btn_lg"] forState:UIControlStateNormal];
    [done setTitleColor:[UIColor HATextColor] forState:UIControlStateNormal];
    //    [self.nextButton setTitleColor:[UIColor colorWithWhite:1.f alpha:0.1] forState:UIControlStateDisabled];
    [done setTranslatesAutoresizingMaskIntoConstraints:NO];
    [done addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [done.titleLabel setFont:STKBoldFont(13)];
    [done addSubview:self.nextButton];
    [cell addSubview:done];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-84-[nb]-84-|" options:0 metrics:nil views:@{@"nb": done}]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-108-[nb(==46)]-0-|" options:0 metrics:nil views:@{@"nb": done}]];
    return cell;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField atIndexPath:(NSIndexPath *)ip
{
    [self setEditingIndexPath:ip];
}

- (void)textFieldDidChange:(UITextField *)sender atIndexPath:(NSIndexPath *)ip {
    if (ip.row == 0) {
        [self.values setObject:sender.text forKey:@"first"];
    } else if (ip.row == 1) {
        [self.values setObject:sender.text forKey:@"last"];
    } else {
        [self.values setObject:sender.text forKey:@"email"];
    }
    if (self.firstNameField.text.length > 0 && self.lastNameField.text.length > 0 && self.emailField.text.length > 0) {
        [self.nextButton setEnabled:YES];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField atIndexPath:(NSIndexPath *)ip {
    return NO;
}

- (void)keyboardWillAppear:(NSNotification *)note
{
//    [[self verticalController] setBackButtonHidden:YES];
    
    CGRect r = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, r.size.height, 0)];
    
//    [[self topOffset] setConstant:-[[self topContainer] bounds].size.height + 64];
    
    [UIView animateWithDuration:[[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]
                          delay:0
                        options:[[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                     animations:^{
                         [[self view] layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
//    [[self verticalController] setBackButtonHidden:NO];
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [[self topOffset] setConstant:[self topOffsetConstant]];
}

@end
