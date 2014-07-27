//
//  STKIntroViewController.m
//  Prism
//
//  Created by Jonathan Boone on 7/25/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKIntroViewController.h"

NSString *const STKIntroCompletedKey = @"STKIntroCompletedKey";

@interface STKIntroViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *imageNames;

- (IBAction)buttonTapped:(id)sender;

@end

@implementation STKIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageNames = @[@"intro_1", @"intro_2"];
    [self configure];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STKIntroCompletedKey];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configure
{
    [self.scrollView setDelegate:self];
    NSArray *names = self.imageNames;
    for (NSInteger i = 0; i != [names count]; ++i) {
        NSString *name = names[i];
        UIImage *img = [UIImage imageNamed:name];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        CGRect frame = self.view.bounds;
        frame.origin.x = frame.size.width * i;
        [iv setFrame:frame];
        if (i == [names count] - 1) {
            CGPoint center = self.view.center;
            center.y = self.view.bounds.size.height - 80;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
            [iv setUserInteractionEnabled:YES];
            [button setCenter:center];
            [button setTitle:@"Begin" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [iv addSubview:button];
        }
        [self.scrollView addSubview:iv];
    }
    
    [self.pageControl setNumberOfPages:[names count]];
    
    NSInteger contentWidth = self.view.bounds.size.width;
    contentWidth = contentWidth * [names count];
    [self.scrollView setContentSize:CGSizeMake(contentWidth, self.view.bounds.size.height)];
    [self.scrollView setContentMode:UIViewContentModeCenter];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self.pageControl setCurrentPage:page];
}

@end
