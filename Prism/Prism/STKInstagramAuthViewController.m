//
//  STKInstagramAuthViewController.m
//  Prism
//
//  Created by Joe Conway on 4/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKInstagramAuthViewController.h"
#import "STKProcessingView.h"

@interface STKInstagramAuthViewController () <UIWebViewDelegate, UIAlertViewDelegate>
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [STKProcessingView present];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [STKProcessingView dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [STKProcessingView dismiss];
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_background"]];
    [iv setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [view addSubview:iv];
    
    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [av setFrame:CGRectMake(160 - 15, 100, 30, 30)];
    [view addSubview:av];
    [av startAnimating];
    
    UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [[wv scrollView] setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [wv setOpaque:NO];
    [wv setBackgroundColor:[UIColor clearColor]];
    [wv setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _webView = wv;
    [wv setDelegate:self];
    [view addSubview:wv];
    
    [self setView:view];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *string = [[request URL] absoluteString];

    NSLog(@"request %@", string);
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"access_token=([^&]*)" options:0 error:nil];
    NSTextCheckingResult *result = [exp firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if([result numberOfRanges] == 2) {
        NSString *accessToken = [string substringWithRange:[result rangeAtIndex:1]];
        if([self tokenFound]) {
            [self tokenFound](accessToken);
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your Instagram account is now connected to your Prizm account. Use #prizm in your Instagram posts and they will automatically be added to your Prizm profile."
                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];

            //[[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://instagram.com/accounts/manage_access"]]];
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://instagram.com/oauth/authorize/?client_id=9fd051f75f184a95a1a4e934e6353ae7&response_type=token&redirect_uri=http://prismoauth.com"]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [[self webView] loadRequest:req];
}

@end
