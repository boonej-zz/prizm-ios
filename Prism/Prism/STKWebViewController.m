//
//  STKWebViewController.m
//  Prism
//
//  Created by Joe Conway on 12/12/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKWebViewController.h"
#import "UIERealTimeBlurView.h"

@interface STKWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;

@end

@implementation STKWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                   target:self
                                                                                                   action:@selector(done:)]];
    }
    return self;
}

- (void)done:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    if([self isViewLoaded] && _url) {
        [[self webView] loadRequest:[NSURLRequest requestWithURL:[self url]]];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self url])
        [[self webView] loadRequest:[NSURLRequest requestWithURL:[self url]]];
}

@end
