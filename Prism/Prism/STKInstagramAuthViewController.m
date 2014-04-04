//
//  STKInstagramAuthViewController.m
//  Prism
//
//  Created by Joe Conway on 4/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInstagramAuthViewController.h"

@interface STKInstagramAuthViewController () <UIWebViewDelegate>
@property (nonatomic, readonly) UIWebView *webView;
@end

@implementation STKInstagramAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}


- (void)loadView
{
    UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectZero];
    [wv setDelegate:self];
    [self setView:wv];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *string = [[request URL] absoluteString];

    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"access_token=([^&]*)" options:0 error:nil];
    NSTextCheckingResult *result = [exp firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if([result numberOfRanges] == 2) {
        NSString *accessToken = [string substringWithRange:[result rangeAtIndex:1]];
        if([self tokenFound]) {
            [self tokenFound](accessToken);
            [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://instagram.com/accounts/manage_access"]]];
            return NO;
        }
    }
    
    return YES;
}

- (UIWebView *)webView
{
    return (UIWebView *)[self view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://instagram.com/oauth/authorize/?client_id=9fd051f75f184a95a1a4e934e6353ae7&response_type=token&redirect_uri=http://prismoauth.com"]]];
}

@end
