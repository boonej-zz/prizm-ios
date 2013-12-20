//
//  STKWebViewController.m
//  Prism
//
//  Created by Joe Conway on 12/12/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKWebViewController.h"

@interface STKWebViewController () <UIWebViewDelegate>

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
        [(UIWebView *)[self view] loadRequest:[NSURLRequest requestWithURL:[self url]]];
    }
}

- (void)loadView
{
    UIWebView *wv = [[UIWebView alloc] init];
    [self setView:wv];
    [wv setDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self url])
        [(UIWebView *)[self view] loadRequest:[NSURLRequest requestWithURL:[self url]]];
}

@end
