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


@interface HAConsentViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *headingLabel;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UITextField *firstNameField;
@property (nonatomic, strong) UITextField *lastNameField;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UIView *wrap1;
@property (nonatomic, strong) UIView *wrap2;
@property (nonatomic, strong) UIView *wrap3;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation HAConsentViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setupViews];
        [self addConstraints];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundImage];
    // Do any additional setup after loading the view.
    self.title = @"Parental Consent";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews
{
    NSString *message = @"Looks like you're under 13. In order to use Prizm we need to notify a parent that you signed up.";
    self.headingLabel = [[UILabel alloc] init];
    [self.headingLabel setText:@"Enter your parent's information"];
    [self.headingLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.headingLabel setFont:STKBoldFont(18)];
    [self.headingLabel setTextColor:[UIColor HATextColor]];
    [self.headingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.headingLabel];
    self.messageTextView = [[UITextView alloc] init];
    [self.messageTextView setText:message];
    [self.messageTextView setEditable:NO];
    [self.messageTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageTextView setFont:STKFont(16)];
    [self.messageTextView setTextColor:[UIColor HATextColor]];
    [self.messageTextView setBackgroundColor:[UIColor clearColor]];
    [self.messageTextView setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.messageTextView];
    self.wrap1 = [[UIView alloc] init];
    [self.wrap1 setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.wrap1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.wrap1];
    self.wrap2 = [[UIView alloc] init];
    [self.wrap2 setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.wrap2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.wrap2];
    self.wrap3 = [[UIView alloc] init];
    [self.wrap3 setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.wrap3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.wrap3];
    self.firstNameField = [[UITextField alloc] init];
    [self.firstNameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Parent's first name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [self.firstNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.firstNameField setBackgroundColor:[UIColor clearColor]];
    [self.firstNameField setFont:STKFont(16)];
    [self.firstNameField setTextColor:[UIColor HATextColor]];
    [self.firstNameField setDelegate:self];

    [self.wrap1 addSubview:self.firstNameField];
    self.lastNameField = [[UITextField alloc] init];
    [self.lastNameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Parent's last name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [self.lastNameField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.lastNameField setBackgroundColor:[UIColor clearColor]];
    [self.lastNameField setFont:STKFont(16)];
    [self.lastNameField setTextColor:[UIColor HATextColor]];
    [self.lastNameField setDelegate:self];
    [self.wrap2 addSubview:self.lastNameField];
    self.emailField = [[UITextField alloc] init];
    [self.emailField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Parent's email address" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [self.emailField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.emailField setBackgroundColor:[UIColor clearColor]];
    [self.emailField setFont:STKFont(16)];
    [self.emailField setTextColor:[UIColor HATextColor]];
    [self.emailField setDelegate:self];
    [self.wrap3 addSubview:self.emailField];
    self.nextButton = [[UIButton alloc] init];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setEnabled:NO];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"btn_lg"] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor HATextColor] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor colorWithWhite:1.f alpha:0.1] forState:UIControlStateDisabled];
    [self.nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
}

- (void)addConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-72-[hl]-16-[mt(==100)]-16-[w1(==46)]-2-[w2(==46)]-2-[w3(==46)]-80-[nb(==46)]" options:0 metrics:nil views:@{@"hl": self.headingLabel, @"mt": self.messageTextView, @"w1": self.wrap1, @"w2": self.wrap2, @"w3": self.wrap3, @"nb": self.nextButton}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[hl]-8-|" options:0 metrics:nil views:@{@"hl": self.headingLabel}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[mt]-8-|" options:0 metrics:nil views:@{@"mt": self.messageTextView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[w1]-0-|" options:0 metrics:nil views:@{@"w1": self.wrap1}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[w2]-0-|" options:0 metrics:nil views:@{@"w2": self.wrap2}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[w3]-0-|" options:0 metrics:nil views:@{@"w3": self.wrap3}]];
    [self.wrap1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[fn]-8-|" options:0 metrics:nil views:@{@"fn": self.firstNameField}]];
    [self.wrap1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[fn]-0-|" options:0 metrics:nil views:@{@"fn": self.firstNameField}]];
    [self.wrap2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[ln]-8-|" options:0 metrics:nil views:@{@"ln": self.lastNameField}]];
    [self.wrap2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[ln]-0-|" options:0 metrics:nil views:@{@"ln": self.lastNameField}]];
    [self.wrap3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[em]-8-|" options:0 metrics:nil views:@{@"em": self.emailField}]];
    [self.wrap3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[em]-0-|" options:0 metrics:nil views:@{@"em": self.emailField}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[nb]-10-|" options:0 metrics:nil views:@{@"nb": self.nextButton}]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.firstNameField.text.length > 0 && self.lastNameField.text.length > 0 && self.emailField.text.length > 0) {
        [self.nextButton setEnabled:YES];
    }
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
    NSDictionary *parent = @{@"first": self.firstNameField.text, @"last": self.lastNameField.text, @"email": self.emailField.text};
    __block UIViewController *menuController = [self presentingViewController];
    [[STKUserStore store] submitParentConsent:parent forUser:self.user completion:^(STKUser *user, NSError *err) {
        [self dismissViewControllerAnimated:NO completion:^{
            HAInterestsViewController *ivc = [[HAInterestsViewController alloc] init];
            [ivc setUser:self.user];
            HANavigationController *nvc = [[HANavigationController alloc] init];
            [nvc addChildViewController:ivc];
            [menuController presentViewController:nvc animated:NO completion:nil];
        }];
    }];
}

@end
