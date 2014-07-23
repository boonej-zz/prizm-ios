//
//  STKWebViewController.m
//  Prism
//
//  Created by Joe Conway on 12/12/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKWebViewController.h"
#import "UIERealTimeBlurView.h"
@import MobileCoreServices;
@import MessageUI;

@interface STKWebViewController () <UIWebViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIERealTimeBlurView *blurView;
@property (nonatomic, strong) MFMessageComposeViewController *messageViewController;
@end

@implementation STKWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_cancelb"]
                                                  landscapeImagePhone:nil
                                                                style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(done:)];
        [bbi setTintColor:[UIColor whiteColor]];
        [[self navigationItem] setLeftBarButtonItem:bbi];
        
        bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_shareoutb"]
                                 landscapeImagePhone:nil
                                               style:UIBarButtonItemStylePlain
                                              target:self action:@selector(sharePage:)];
        [bbi setTintColor:[UIColor whiteColor]];

        [[self navigationItem] setRightBarButtonItem:bbi];
        
    
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[[self navigationController] navigationBar] setTintColor:[UIColor whiteColor]];
}


- (void)sharePage:(id)sender
{
    UIActionSheet *sheet = nil;
    
    if(![MFMessageComposeViewController canSendText]) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Open in Safari", @"Copy Link", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Open in Safari", @"Copy Link", @"Send as Message", nil];
        
    }
    
    [sheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[[[self webView] request] URL]];
    } else if(buttonIndex == 1) {
        [[UIPasteboard generalPasteboard] setURL:[[[self webView] request] URL]];
    } else if(buttonIndex == 2) {
        if([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
            [vc setMessageComposeDelegate:self];
            [vc setBody:[[[[self webView] request] URL] absoluteString]];
            [self presentViewController:vc animated:YES completion:nil];
            
            [self setMessageViewController:vc];
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setMessageViewController:nil];
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
    
    [[self navigationItem] setTitle:[url host]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self blurView] setOverlayOpacity:0.5];
    if([self url])
        [[self webView] loadRequest:[NSURLRequest requestWithURL:[self url]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[STKErrorStore alertViewForError:error delegate:nil] show];
}

@end
